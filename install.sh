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

# ----------- Lecture du chemin d'installation -----------

if [ -t 0 ]; then
  read -rp "📦 Chemin d'installation de SeedDock [default: ${HOME}/SeedDock] : " custom_path
  INSTALL_DIR="${custom_path:-${HOME}/SeedDock}"
else
  INSTALL_DIR="${HOME}/SeedDock"
  echo_info "Mode non interactif détecté, utilisation de : ${INSTALL_DIR}"
fi

# ----------- Clonage du dépôt -----------
if [ -z "${INSTALL_DIR}" ]; then
  echo_error "Le chemin d'installation est vide. Abandon."
  exit 1
fi

if [ -d "${INSTALL_DIR}" ]; then
  echo_warn "Le dossier ${INSTALL_DIR} existe déjà."
else
  echo_info "Clonage du dépôt SeedDock dans ${INSTALL_DIR}..."
  git clone https://github.com/matt-prod/seeddock "${INSTALL_DIR}" || {
    echo_error "Échec du clonage du dépôt."
    exit 1
  }
fi

# ----------- Préparation de l'exécution ------------

# Stocker le chemin pour reprise
echo "${INSTALL_DIR}" > "${INSTALL_DIR}/.install_dir"

# Rendre le script exécutable
chmod +x "${INSTALL_DIR}/seeddock.sh"

# Lancer le script
echo_info "Lancement de l'installation avec seeddock.sh..."
bash "${INSTALL_DIR}/seeddock.sh"
