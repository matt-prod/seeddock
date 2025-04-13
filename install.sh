#!/bin/bash

# ----------- Couleurs -----------
CEND="\033[0m"
CBLUE="\033[1;34m"
CYELLOW="\033[1;33m"
CRED="\033[1;31m"

echo_info() { echo -e "${CBLUE}[INFO]${CEND} $1"; }
echo_warn() { echo -e "${CYELLOW}[WARN]${CEND} $1"; }
echo_error() { echo -e "${CRED}[ERROR]${CEND} $1"; }

# ----------- Vérification Git -----------
if ! command -v git &>/dev/null; then
  echo_info "Installation de Git..."
  sudo apt update && sudo apt install -y git || {
    echo_error "Échec de l'installation de Git."
    exit 1
  }
else
  echo_info "Git déjà installé."
fi

# ----------- Clonage du dépôt -----------
INSTALL_DIR="${HOME}/SeedDock"

if [ -d "${INSTALL_DIR}" ]; then
  echo_warn "Le dossier ${INSTALL_DIR} existe déjà."
else
  echo_info "Clonage du dépôt SeedDock dans ${INSTALL_DIR}..."
  git clone https://github.com/matt-prod/seeddock "${INSTALL_DIR}" || {
    echo_error "Échec du clonage du dépôt."
    exit 1
  }
fi

# ----------- Reprise automatique -----------
RESUME_FLAG="${HOME}/.resume_seeddock"
BASHRC="${HOME}/.bashrc"

if ! grep -q 'seeddock.sh' "${BASHRC}"; then
  echo_info "Préparation de la reprise automatique après reconnexion..."
  echo "[ -f \"${RESUME_FLAG}\" ] && bash \"${INSTALL_DIR}/seeddock.sh\" && rm -f \"${RESUME_FLAG}\"" >> "${BASHRC}"
  touch "${RESUME_FLAG}"
fi

echo_info "Ajout du profil SeedDock dans .bashrc..."

PROFILE_LINE="source \"${INSTALL_DIR}/includes/profile.sh\""
if ! grep -q "${PROFILE_LINE}" "${HOME}/.bashrc"; then
  echo "${PROFILE_LINE}" >> "${HOME}/.bashrc"
fi

# ----------- Exécution -----------
echo_info "Lancement de l'installation avec seeddock.sh..."
chmod +x "${INSTALL_DIR}/seeddock.sh"
bash "${INSTALL_DIR}/seeddock.sh"
