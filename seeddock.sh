#!/bin/bash

# ------------- Chargement des includes -------------
INCLUDES_DIR="$(dirname "${BASH_SOURCE[0]}")/includes"

if [ ! -f "${INCLUDES_DIR}/functions.sh" ] || [ ! -f "${INCLUDES_DIR}/variables.sh" ]; then
  echo -e "\033[1m[ERREUR]\033[0m Fichiers d'includes manquants."
  exit 1
fi

source "${INCLUDES_DIR}/variables.sh"
source "${INCLUDES_DIR}/functions.sh"
[ -f "${INCLUDES_DIR}/logo.sh" ] && source "${INCLUDES_DIR}/logo.sh"

# ------------- Affichage logo -------------
show_logo

# ------------- Reprise automatique / initialisation -------------
if [ ! -f "${STATUS_FILE}" ]; then
  echo "0" > "${STATUS_FILE}"
fi

STEP="$(cat "${STATUS_FILE}")"

if [ -f "${RESUME_FLAG}" ]; then
  echo_info "[REPRISE] Suite de l'installation à partir de l'étape ${STEP}"
  rm -f "${RESUME_FLAG}"
fi

# ------------- Exécution progressive des étapes -------------
case "${STEP}" in
  0)
    run_step "Vérification de l'environnement" verify_os
    check_not_root
    install_git
    install_docker
    setup_user_groups

    # Préparer la reprise automatique après relog
    if ! grep -q 'seeddock.sh' "${HOME}/.bashrc"; then
      echo_info "Préparation de la reprise automatique après reconnexion..."
      echo "[ -f \"${RESUME_FLAG}\" ] && bash \"${INSTALL_DIR}/seeddock.sh\" && rm -f \"${RESUME_FLAG}\"" >> "${HOME}/.bashrc"
      touch "${RESUME_FLAG}"
    fi

    echo_warn "Délogguez puis reconnectez-vous. La suite s'exécutera automatiquement."
    echo "1" > "${STATUS_FILE}"
    exit 0
    ;;

  1)
    run_step "Création des dossiers et configuration de base" create_project_structure
    generate_vault_pass
    copy_ansible_templates
    echo "2" > "${STATUS_FILE}"
    ;;

  2)
    run_step "Déploiement de Traefik (bootstrap)" deploy_traefik_bootstrap
    echo "3" > "${STATUS_FILE}"
    ;;

  3)
    run_step "Lancement du conteneur SDM" deploy_sdm_container
    echo_info "✅ Installation terminée. Accédez à la WebUI via: https://<IP>/"
    echo "4" > "${STATUS_FILE}"
    ;;

  *)
    echo_info "✅ L'installation est déjà terminée. Rien à faire."
    ;;
esac
