#!/bin/bash

# ----------- Chargement des includes -----------
INCLUDES_DIR="$(dirname "${BASH_SOURCE[0]}")/includes"

if [ ! -f "${INCLUDES_DIR}/functions.sh" ] || [ ! -f "${INCLUDES_DIR}/variables.sh" ]; then
  echo -e "\033[1m[ERREUR]\033[0m Fichiers d'includes manquants."
  exit 1
fi

source "${INCLUDES_DIR}/variables.sh"
source "${INCLUDES_DIR}/functions.sh"
[ -f "${INCLUDES_DIR}/logo.sh" ] && source "${INCLUDES_DIR}/logo.sh"

show_logo

# ----------- Reprise auto -----------
[ -f "${STATUS_FILE}" ] || echo "0" > "${STATUS_FILE}"
STEP="$(cat "${STATUS_FILE}" 2>/dev/null || echo 0)"

if [ -f "${RESUME_FLAG}" ]; then
  echo_info "[REPRISE] Suite de l'installation à partir de l'étape ${STEP}"
  rm -f "${RESUME_FLAG}"
fi

# ----------- Étapes -----------
while true; do
  case "${STEP}" in
    0)
      run_step "Vérification de l'environnement" verify_os
      check_not_root
      install_git
      install_docker
      setup_user_groups

      echo_warn "Délogguez puis reconnectez-vous. La suite s'exécutera automatiquement."
      echo "1" > "${STATUS_FILE}"
      touch "${RESUME_FLAG}"
      exit 0
      ;;
    1)
      run_step "Création des dossiers et configuration de base" create_project_structure
      create_inventory_file
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
      break
      ;;
  esac

  STEP=$(cat "${STATUS_FILE}")
done
