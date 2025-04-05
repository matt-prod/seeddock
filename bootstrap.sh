#!/bin/bash

set -e

# -------- Config par défaut --------
REPO_URL="https://github.com/matt-prod/seeddock.git"
INSTALL_DIR="$HOME/SeedDock"

# -------- Fonctions utilitaires --------
info()    { echo -e "\e[34m[INFO]\e[0m $1"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $1"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $1"; }

# -------- Vérifs --------
if [ "$EUID" -eq 0 ]; then
  error "Ne pas lancer ce script en tant que root."
  exit 1
fi

if ! command -v git &>/dev/null; then
  info "Git non détecté. Installation..."
  sudo apt update && sudo apt install -y git
fi

# -------- Clonage --------
if [ -d "$INSTALL_DIR" ]; then
  warn "Le dossier $INSTALL_DIR existe déjà."
else
  info "Clonage de SeedDock dans $INSTALL_DIR..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

# -------- Lancement --------
cd "$INSTALL_DIR"
chmod +x start.sh
exec ./start.sh
