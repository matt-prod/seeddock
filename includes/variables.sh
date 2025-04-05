#!/bin/bash

# ------------- Couleurs Terminal -------------
CEND="\033[0m"
CRED="\033[1;31m"
CGREEN="\033[1;32m"
CYELLOW="\033[1;33m"
CBLUE="\033[1;34m"
CMAGENTA="\033[1;35m"
CGRAY="\033[1;90m"

# ------------- Variables générales -------------
VERSION=$(cat "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/VERSION")
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
MONDEDIE="MONDEDIE"

# ------------- Variables de chemin par défaut -------------
INSTALL_DIR="${HOME}/SeedDock"
CONFIG_DIR="${INSTALL_DIR}/SDM/config"
STATUS_FILE="${INSTALL_DIR}/.seeddock_step"
RESUME_FLAG="${INSTALL_DIR}/.resume_seeddock"

STEP=0
