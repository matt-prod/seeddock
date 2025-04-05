#!/bin/bash

# ------------- Couleurs Terminal -------------
CEND="\033[0m"
CRED="\033[1;31m"
CGREEN="\033[1;32m"
CYELLOW="\033[1;33m"
CBLUE="\033[1;34m"
CMAGENTA="\033[1;35m"
CGRAY="\033[1;90m"

# ------------- Variables de chemin par défaut -------------
INSTALL_DIR="${HOME}/SeedDock"
CONFIG_DIR="${INSTALL_DIR}/SDM/config"
INCLUDES_DIR="${INSTALL_DIR}/includes"
RESUME_FLAG="${HOME}/.resume_seeddock"
STATUS_FILE="${INSTALL_DIR}/.seeddock_step"

VERSION=$(cat "${INSTALL_DIR}/VERSION" 2>/dev/null || echo "dev")
STEP=0
