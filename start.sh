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

# Init vars
DEFAULT_INSTALL_DIR="$HOME/SeedDock"
SD_STATUS_FILE="$DEFAULT_INSTALL_DIR/.sd_status"

# Charger l'état d'avancement
if [ -f "$SD_STATUS_FILE" ]; then
  source "$SD_STATUS_FILE"
else
  STEP=0
fi

# Step runner
case $STEP in
  0)
    echo_info "\n[Étape 0] Vérification de l'environnement..."
    verify_os
    check_not_root
    install_git
    install_docker
    setup_user_groups

    mkdir -p "$DEFAULT_INSTALL_DIR"
    echo "STEP=1" > "$SD_STATUS_FILE"

    echo_warn "\nRedémarrez votre session (délog/relog), puis relancez start.sh."
    exit 0
    ;;
  1)
    echo_info "\n[Étape 1] Création des dossiers et configuration de base..."
    prompt_install_path
    create_project_structure
    generate_vault_pass
    init_ansible_cfg
    echo "STEP=2" > "$SD_STATUS_FILE"
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
    echo "STEP=3" > "$SD_STATUS_FILE"
    exec "$0"
    ;;
  3)
    echo_info "\n[Étape 3] Lancement du conteneur SDM..."
    deploy_sdm_container
    echo "✅ Installation terminée. Accédez à la WebUI via: https://<IP>/sdm"
    echo "STEP=4" > "$SD_STATUS_FILE"
    ;;
  *)
    echo_info "\n✅ Toutes les étapes ont déjà été réalisées. Rien à faire."
    ;;
esac
