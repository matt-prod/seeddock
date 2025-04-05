#!/bin/bash

# Couleurs de base
CEND="\e[0m"
CRED="\e[31m"
CGREEN="\e[32m"
CYELLOW="\e[33m"
CBLUE="\e[34m"
CMAGENTA="\e[35m"
CCYAN="\e[36m"
CGRAY="\e[90m"

# Version du projet
VERSION="0.0.1"

# Variables dynamiques (définies au runtime)
INSTALL_DIR="${INSTALL_DIR:-$HOME/SeedDock}"
CONFIG_DIR="${CONFIG_DIR:-$INSTALL_DIR/SDM/config}"
INCLUDES_DIR="${INCLUDES_DIR:-$INSTALL_DIR/includes}"

# Status file
SD_STATUS_FILE="${SD_STATUS_FILE:-$INSTALL_DIR/.sd_status}"
