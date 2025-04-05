#!/bin/bash

# ------------- Log Helpers -------------

echo_info() {
  echo -e "${CBLUE}[INFO]${CEND} $1"
}

echo_warn() {
  echo -e "${CYELLOW}[WARN]${CEND} $1"
}

echo_error() {
  echo -e "${CRED}[ERROR]${CEND} $1"
}

# ------------- Vérification OS -------------

verify_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      debian|ubuntu)
        echo_info "OS détecté : $PRETTY_NAME"
        ;;
      *)
        echo_error "OS non supporté ($ID)."
        exit 1
        ;;
    esac
  else
    echo_error "Impossible de détecter le système."
    exit 1
  fi
}

check_not_root() {
  if [ "$EUID" -eq 0 ]; then
    echo_error "Ne pas exécuter ce script en tant que root."
    exit 1
  fi
}

# ------------- Installers -------------

install_git() {
  if ! command -v git &>/dev/null; then
    echo_info "Installation de Git..."
    sudo apt update && sudo apt install -y git
  else
    echo_info "Git déjà installé."
  fi
}

install_docker() {
  if ! command -v docker &>/dev/null; then
    echo_info "Installation de Docker via script officiel..."
    curl -fsSL https://get.docker.com | sudo sh
  else
    echo_info "Docker déjà installé."
  fi
}

setup_user_groups() {
  echo_info "Ajout de l'utilisateur aux groupes sudo et docker..."
  sudo usermod -aG sudo "$USER"
  sudo usermod -aG docker "$USER"
  echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/$USER" >/dev/null
}

# ------------- Structure -------------

prompt_install_path() {
  read -rp "📦 Chemin d'installation de SeedDock [default: $INSTALL_DIR] : " custom_path
  if [ -n "$custom_path" ]; then
    INSTALL_DIR="$custom_path"
    CONFIG_DIR="$INSTALL_DIR/SDM/config"
  fi
  export INSTALL_DIR CONFIG_DIR
}

create_project_structure() {
  echo_info "Création des dossiers..."
  mkdir -p "$INSTALL_DIR/includes"
  mkdir -p "$INSTALL_DIR/containers/traefik/config"
  mkdir -p "$INSTALL_DIR/SDM/config"
  mkdir -p "$INSTALL_DIR/SDM/inventory"
  mkdir -p "$INSTALL_DIR/SDM/playbooks"
}

# ------------- Vault & Ansible -------------

generate_vault_pass() {
  echo_info "Génération du fichier vault_pass..."
  head -c 24 /dev/urandom | base64 > "$CONFIG_DIR/vault_pass"
  chmod 600 "$CONFIG_DIR/vault_pass"

  echo_info "Création de all.yml minimal..."
  mkdir -p "$INSTALL_DIR/SDM/group_vars"
  echo -e "user:\n  name: \"\"" > "$INSTALL_DIR/SDM/group_vars/all.yml"
}

init_ansible_cfg() {
  echo_info "Initialisation du fichier ansible.cfg..."
  cat <<EOF > "$INSTALL_DIR/SDM/ansible.cfg"
[defaults]
inventory = ./inventory
vault_password_file = ./config/vault_pass
host_key_checking = False
retry_files_enabled = False
EOF
}

# ------------- Déploiement Traefik -------------

deploy_traefik_bootstrap() {
  echo_info "Déploiement de Traefik (bootstrap)..."
  ensure_traefik_network

  CERTS_PATH="$INSTALL_DIR/containers/traefik/config/certs"
  mkdir -p "$CERTS_PATH"

  if [ ! -f "$CERTS_PATH/traefik.crt" ]; then
    echo_info "Génération certificat autosigné..."
    openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
      -keyout "$CERTS_PATH/traefik.key" \
      -out "$CERTS_PATH/traefik.crt" \
      -subj "/CN=localhost" \
      -addext "subjectAltName=IP:127.0.0.1"
  fi

  docker run -d --name traefik_bootstrap \
    --restart unless-stopped \
    --network traefik \
    -p 80:80 -p 443:443 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$INSTALL_DIR/containers/traefik/config/traefik.yml:/etc/traefik/traefik.yml" \
    -v "$CERTS_PATH:/certs" \
    -l "traefik.enable=true" \
    -l "traefik.http.routers.sdm.rule=PathPrefix(`/sdm`)" \
    -l "traefik.http.routers.sdm.entrypoints=websecure" \
    -l "traefik.http.routers.sdm.tls=true" \
    traefik:v3.0
}

# ------------- Déploiement SDM -------------

deploy_sdm_container() {
  echo_info "Lancement de whoami (test à la place de SDM)..."
  docker run -d --name sdm \
    --restart unless-stopped \
    --network traefik \
    -l "traefik.enable=true" \
    -l "traefik.http.routers.sdm.rule=PathPrefix(`/sdm`)" \
    -l "traefik.http.routers.sdm.entrypoints=websecure" \
    -l "traefik.http.routers.sdm.tls=true" \
    traefik/whoami
}

ensure_traefik_network() {
  if ! docker network ls | grep -q 'traefik'; then
    echo_info "Création du network Docker 'traefik'..."
    docker network create traefik
  else
    echo_info "Network 'traefik' déjà existant."
  fi
}