#!/bin/bash

# ------------- Log Helpers -------------

echo_info() {
  echo -e "\033[36m[INFO]\033[0m $1"
}

echo_warn() {
  echo -e "\033[33m[WARN]\033[0m $1"
}

echo_error() {
  echo -e "\033[31m[ERROR]\033[0m $1"
}

# ------------- Vérification OS -------------

verify_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "${ID}" in
      debian|ubuntu)
        echo_info "OS détecté : ${PRETTY_NAME}"
        ;;
      *)
        echo_error "OS non supporté (${ID})"
        exit 1
        ;;
    esac
  else
    echo_error "Impossible de détecter le système"
    exit 1
  fi
}

check_not_root() {
  if [ "${EUID}" -eq 0 ]; then
    echo_error "Ne pas exécuter ce script en tant que root"
    exit 1
  fi
}

# ------------- Installations -------------

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
  sudo usermod -aG sudo "${USER}"
  sudo usermod -aG docker "${USER}"
  echo "${USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/${USER}" >/dev/null
}

# ------------- Structure du projet -------------

prompt_install_path() {
  if [ -t 0 ]; then
    read -rp "📦 Chemin d'installation de SeedDock [default: ${INSTALL_DIR}] : " custom_path
    if [ -n "${custom_path}" ]; then
      INSTALL_DIR="${custom_path}"
      CONFIG_DIR="${INSTALL_DIR}/SDM/config"
    fi
  else
    echo_info "Mode non interactif détecté, utilisation de : ${INSTALL_DIR}"
  fi
  export INSTALL_DIR CONFIG_DIR
}

create_project_structure() {
  echo_info "Création des dossiers..."
  mkdir -p "${INSTALL_DIR}/includes"
  mkdir -p "${INSTALL_DIR}/containers/traefik/config"
  mkdir -p "${INSTALL_DIR}/SDM/config"
  mkdir -p "${INSTALL_DIR}/SDM/inventory"
  mkdir -p "${INSTALL_DIR}/SDM/playbooks"
  mkdir -p "${INSTALL_DIR}/SDM/group_vars"
}

# ------------- Vault & Ansible -------------

generate_vault_pass() {
  echo_info "Génération du fichier vault_pass..."
  head -c 24 /dev/urandom | base64 > "${CONFIG_DIR}/vault_pass"
  chmod 600 "${CONFIG_DIR}/vault_pass"
}

copy_ansible_templates() {
  echo_info "Copie du template all.yml..."
  cp "${INCLUDES_DIR}/templates/all.yml" "${INSTALL_DIR}/SDM/group_vars/all.yml"

  echo_info "Initialisation du fichier ansible.cfg..."
  cp "${INCLUDES_DIR}/templates/ansible.cfg" "${INSTALL_DIR}/SDM/ansible.cfg"
}

# ------------- Déploiement Traefik -------------

deploy_traefik_bootstrap() {
  echo_info "Déploiement de Traefik (bootstrap)..."
  ensure_traefik_network

  local CERTS_PATH="${INSTALL_DIR}/containers/traefik/config/certs"
  mkdir -p "${CERTS_PATH}"

  if [ ! -f "${CERTS_PATH}/traefik.crt" ]; then
    echo_info "Génération certificat autosigné..."
    openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
      -keyout "${CERTS_PATH}/traefik.key" \
      -out "${CERTS_PATH}/traefik.crt" \
      -subj "/CN=localhost" \
      -addext "subjectAltName=IP:127.0.0.1"
  fi

  docker run -d --name traefik_bootstrap \
    --restart unless-stopped \
    --network traefik \
    -p 80:80 -p 443:443 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "${INSTALL_DIR}/containers/traefik/config/traefik.yml:/etc/traefik/traefik.yml" \
    -v "${CERTS_PATH}:/certs" \
    traefik:v3.0
}

# ------------- Déploiement SDM -------------

deploy_sdm_container() {
  echo_info "Lancement de SeedDock Manager (SDM)..."
  docker run -d --name sdm \
    --restart unless-stopped \
    --network traefik \
    -v "${INSTALL_DIR}/SDM:/srv/sdm" \
    -v "${INSTALL_DIR}/includes:/srv/sdm/includes" \
    -l "traefik.enable=true" \
    -l "traefik.http.routers.sdm.rule=PathPrefix('/')" \
    -l "traefik.http.routers.sdm.entrypoints=websecure" \
    -l "traefik.http.routers.sdm.tls=true" \
    -l "traefik.http.services.sdm.loadbalancer.server.port=8000" \
    ghcr.io/matt-prod/seeddock-manager:latest
}

ensure_traefik_network() {
  if ! docker network ls | grep -q 'traefik'; then
    echo_info "Création du network Docker 'traefik'..."
    docker network create traefik
  else
    echo_info "Network 'traefik' déjà existant."
  fi
}
