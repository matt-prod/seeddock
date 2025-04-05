#!/bin/bash

# Définition chemins et version
INSTALL_DIR="$HOME/SeedDock"
CONFIG_DIR="$INSTALL_DIR/SDM/config"
INCLUDES_DIR="$INSTALL_DIR/includes"
STATUS_FILE="$INSTALL_DIR/.sd_status"
VERSION="0.0.1"

# Chargement des fichiers nécessaires
if [ ! -f "$INCLUDES_DIR/functions.sh" ] || [ ! -f "$INCLUDES_DIR/variables.sh" ] || [ ! -f "$INCLUDES_DIR/logo.sh" ]; then
  echo "[ERREUR] Fichiers d'includes manquants."
  exit 1
fi

source "$INCLUDES_DIR/variables.sh"
source "$INCLUDES_DIR/logo.sh"
source "$INCLUDES_DIR/functions.sh"

# Affichage du logo + infos système
print_logo "$VERSION"

# Initialisation de l'état
STEP=0
[ -f "$STATUS_FILE" ] && STEP=$(cat "$STATUS_FILE")

# Execution progressive
case "$STEP" in
  0)
    run_step "Vérification de l'environnement" verify_os
    check_not_root
    install_git
    install_docker
    setup_user_groups
    echo_warn "Déloguez puis relancez le script : ./seeddock.sh"
    echo 1 > "$STATUS_FILE"
    exit 0
    ;;
  1)
    run_step "Création des dossiers et configuration de base" create_project_structure
    prompt_install_path
    generate_vault_pass
    init_ansible_cfg
    echo 2 > "$STATUS_FILE"
    ;;
  2)
    run_step "Déploiement de Traefik (bootstrap)" deploy_traefik_bootstrap
    echo 3 > "$STATUS_FILE"
    ;;
  3)
    run_step "Lancement du conteneur SDM" deploy_sdm_container
    echo_info "✅ Installation terminée. Accédez à l'interface : https://$(hostname -I | awk '{print $1}')"
    rm -f "$STATUS_FILE"
    ;;
  *)
    echo_info "Installation déjà terminée ou état inconnu."
    ;;
esac
