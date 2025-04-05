#!/bin/bash

# --- Variables temporaires ---
REPO_URL="https://github.com/matt-prod/seeddock"
REPO_RAW="https://raw.githubusercontent.com/matt-prod/seeddock/main"
CLONE_DIR="$HOME/SeedDock"

# --- Vérifie Git ---
if ! command -v git &>/dev/null; then
  echo "[INFO] Git non détecté. Installation..."
  sudo apt update -qq && sudo apt install -y git
fi

# --- Clone si dossier absent ---
if [ ! -d "$CLONE_DIR" ]; then
  echo "[INFO] Clonage du dépôt SeedDock dans $CLONE_DIR..."
  git clone "$REPO_URL" "$CLONE_DIR"
else
  echo "[INFO] Dépôt SeedDock déjà présent. Mise à jour..."
  cd "$CLONE_DIR" && git pull
fi

# --- Lancement du vrai script ---
exec bash "$CLONE_DIR/seeddock.sh"
