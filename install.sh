#!/bin/bash

# ----------- Couleurs -----------
CEND="\033[0m"
CBLUE="\033[1;34m"
CYELLOW="\033[1;33m"
CRED="\033[1;31m"

echo_info() {
  echo -e "${CBLUE}[INFO]${CEND} $1"
}

echo_warn() {
  echo -e "${CYELLOW}[WARN]${CEND} $1"
}

echo_error() {
  echo -e "${CRED}[ERROR]${CEND} $1"
}

# ----------- Vérification de Git -----------
if ! command -v git &>/dev/null; then
  echo_info "Installation de Git..."
  sudo apt update && sudo apt install -y git || {
    echo_error "Échec de l'installation de Git."
    exit 1
  }
else
  echo_info "Git déjà installé."
fi

# ----------- Vérification de Docker -----------
if ! command -v docker &>/dev/null; then
  echo_info "Installation de Docker via script officiel..."
  curl -fsSL https://get.docker.com | sudo sh || {
    echo_error "Échec de l'installation de Docker."
    exit 1
  }
else
  echo_info "Docker déjà installé."
fi

# ----------- Groupes utilisateur -----------
echo_info "Ajout de l'utilisateur aux groupes sudo et docker..."
sudo usermod -aG sudo "${USER}"
sudo usermod -aG docker "${USER}"
echo "${USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/${USER}" >/dev/null

# ----------- Clonage dans ~/SeedDock -----------

INSTALL_DIR="${HOME}/SeedDock"
RESUME_FLAG="${INSTALL_DIR}/.resume_seeddock"
BASHRC="${HOME}/.bashrc"

if [ -d "${INSTALL_DIR}" ]; then
  echo_warn "Le dossier ${INSTALL_DIR} existe déjà."
else
  echo_info "Clonage du dépôt SeedDock dans ${INSTALL_DIR}..."
  git clone https://github.com/matt-prod/seeddock "${INSTALL_DIR}" || {
    echo_error "Échec du clonage du dépôt."
    exit 1
  }
fi

# ----------- Ajout de la reprise automatique -----------

RESUME_FLAG="${INSTALL_DIR}/.resume_seeddock"
BASHRC="${HOME}/.bashrc"

if ! grep -q 'seeddock.sh' "${BASHRC}"; then
  echo_info "Préparation de la reprise automatique après reconnexion..."
  echo "[ -f \"${RESUME_FLAG}\" ] && bash \"${INSTALL_DIR}/seeddock.sh\" && rm -f \"${RESUME_FLAG}\"" >> "${BASHRC}"
  touch "${RESUME_FLAG}"
fi

# ----------- Lancement de seeddock.sh -----------
echo_info "Lancement de l'installation avec seeddock.sh..."
chmod +x "${INSTALL_DIR}/seeddock.sh"
bash "${INSTALL_DIR}/seeddock.sh"
