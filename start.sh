#!/bin/bash

set -e

# ------------------------------
# SeedDock :: start.sh
# ------------------------------
# Bootstrap initial du projet SeedDock
# - Installe Git, Docker
# - Crée l'arborescence du projet
# - Lance traefik_bootstrap
# - Déploie SDM WebUI sur /sdm
# ------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

# Load includes
source "$SCRIPT_DIR/includes/variables.sh"
source "$SCRIPT_DIR/includes/functions.sh"
source "$SCRIPT_DIR/includes/logo.sh"

# Print logo
print_logo

# Init vars (chargement dynamique selon le fichier d'état)
if [ -f "$HOME/SeedDock/.sd_status" ]; then
  source "$HOME/SeedDock/.sd_status"
else
  STEP=0
  INSTALL_DIR="$HOME/SeedDock"
fi

SD_STATUS_FILE="$INSTALL_DIR/.sd_status"

# Step runner
case $STEP in
  0)
    echo_info "\n[Étape 0] Vérification de l'environnement..."
    verify_os
    check_not_root
    install_git
    install_docker
    setup_user_groups

    mkdir -p "$INSTALL_DIR"
    echo "INSTALL_DIR=\"$INSTALL_DIR\"" > "$SD_STATUS_FILE"
    echo "STEP=1" >> "$SD_STATUS_FILE"

    echo_warn "\nRedémarrez votre session (délog/relog), puis relancez le script d'installation :"
    echo_info "  curl -sSL https://raw.githubusercontent.com/matt-prod/seeddock/main/bootstrap.sh | bash"
    exit 0
    ;;
  1)
    echo_info "\n[Étape 1] Création des dossiers et configuration de base..."
    prompt_install_path
    create_project_structure
    generate_vault_pass
    init_ansible_cfg
    echo "INSTALL_DIR=\"$INSTALL_DIR\"" > "$SD_STATUS_FILE"
    echo "STEP=2" >> "$SD_STATUS_FILE"
    exec "$0"
    ;;
  2)
    echo_info "\n[Étape 2] Déploiement de Traefik (bootstrap)..."
    rm -rf "$INSTALL_DIR/containers/traefik/config/traefik.yml"
    echo "# Traefik static config" > "$INSTALL_DIR/containers/traefik/config/traefik.yml"
    cat <<EOF >> "$INSTALL_DIR/containers/traefik/config/traefik.yml"
entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"

providers:
  docker:
    exposedByDefault: false

api:
  dashboard: false
  insecure: false
EOF
    deploy_traefik_bootstrap
    echo "INSTALL_DIR=\"$INSTALL_DIR\"" > "$SD_STATUS_FILE"
    echo "STEP=3" >> "$SD_STATUS_FILE"
    exec "$0"
    ;;
  3)
    echo_info "\n[Étape 3] Lancement du conteneur SDM..."
    deploy_sdm_container
    echo "✅ Installation terminée. Accédez à la WebUI via: https://<IP>/sdm"
    echo "INSTALL_DIR=\"$INSTALL_DIR\"" > "$SD_STATUS_FILE"
    echo "STEP=4" >> "$SD_STATUS_FILE"
    ;;
  *)
    echo_info "\n✅ Toutes les étapes ont déjà été réalisées. Rien à faire."
    ;;
esac