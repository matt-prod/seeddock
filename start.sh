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
  if [ "$STEP" -gt 0 ]; then
    echo_info "[REPRISE] Suite de l'installation à partir de l'étape $STEP"
  fi
else
  STEP=0
  INSTALL_DIR="$HOME/SeedDock"
fi

SD_STATUS_FILE="$INSTALL_DIR/.sd_status"
LOG_FILE="$INSTALL_DIR/seeddock.log"
mkdir -p "$INSTALL_DIR"
touch "$LOG_FILE"

# Step runner
case $STEP in
  0)
    echo_info "\n[Étape 0] Vérification de l'environnement..." | tee -a "$LOG_FILE"
    verify_os | tee -a "$LOG_FILE"
    check_not_root | tee -a "$LOG_FILE"
    install_git | tee -a "$LOG_FILE"
    install_docker | tee -a "$LOG_FILE"
    setup_user_groups | tee -a "$LOG_FILE"

    echo "INSTALL_DIR=\"$INSTALL_DIR\"" > "$SD_STATUS_FILE"
    echo "STEP=1" >> "$SD_STATUS_FILE"

    echo_warn "\nRedémarrez votre session (délog/relog), puis relancez le script d'installation :"
    echo_info "  curl -sSL https://raw.githubusercontent.com/matt-prod/seeddock/main/bootstrap.sh | bash"
    exit 0
    ;;
  1)
    echo_info "\n[Étape 1] Création des dossiers et configuration de base..." | tee -a "$LOG_FILE"
    echo_info ">> [DEBUG] Appel de prompt_install_path" | tee -a "$LOG_FILE"
    prompt_install_path | tee -a "$LOG_FILE"
    echo_info ">> [DEBUG] Fin prompt_install_path" | tee -a "$LOG_FILE"

    echo_info ">> [DEBUG] Appel de create_project_structure" | tee -a "$LOG_FILE"
    create_project_structure | tee -a "$LOG_FILE"
    echo_info ">> [DEBUG] Fin create_project_structure" | tee -a "$LOG_FILE"

    echo_info ">> [DEBUG] Appel de generate_vault_pass" | tee -a "$LOG_FILE"
    generate_vault_pass | tee -a "$LOG_FILE"
    echo_info ">> [DEBUG] Fin generate_vault_pass" | tee -a "$LOG_FILE"

    echo_info ">> [DEBUG] Appel de init_ansible_cfg" | tee -a "$LOG_FILE"
    init_ansible_cfg | tee -a "$LOG_FILE"
    echo_info ">> [DEBUG] Fin init_ansible_cfg" | tee -a "$LOG_FILE"

    echo "INSTALL_DIR=\"$INSTALL_DIR\"" > "$SD_STATUS_FILE"
    echo "STEP=2" >> "$SD_STATUS_FILE"
    exec "$0"
    ;;
  2)
    echo_info "\n[Étape 2] Déploiement de Traefik (bootstrap)..." | tee -a "$LOG_FILE"
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
    deploy_traefik_bootstrap | tee -a "$LOG_FILE"
    echo "INSTALL_DIR=\"$INSTALL_DIR\"" > "$SD_STATUS_FILE"
    echo "STEP=3" >> "$SD_STATUS_FILE"
    exec "$0"
    ;;
  3)
    echo_info "\n[Étape 3] Lancement du conteneur SDM..." | tee -a "$LOG_FILE"
    deploy_sdm_container | tee -a "$LOG_FILE"
    echo "✅ Installation terminée. Accédez à la WebUI via: https://<IP>/sdm" | tee -a "$LOG_FILE"
    echo "INSTALL_DIR=\"$INSTALL_DIR\"" > "$SD_STATUS_FILE"
    echo "STEP=4" >> "$SD_STATUS_FILE"
    ;;
  *)
    echo_info "\n✅ Toutes les étapes ont déjà été réalisées. Rien à faire." | tee -a "$LOG_FILE"
    ;;
esac
