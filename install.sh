#!/usr/bin/env bash
# Copyright (C) 2025 T-Systems International GmbH.
#
# You can find the compulsory statement on:
# https://www.t-systems.com/de/en/compulsory-statement
#
# All rights, including licensing, inspection, modification and sharing of
# software and source code, reserved.

set -euo pipefail


readonly CONF_DIR="~/.config"
readonly INSTALL_DIR="$CONF_DIR/hooked"
readonly REPO_URL="https://github.com/conmob-devsecops/hooked"
readonly PRE_COMMIT_VERSION="4.3.0"

check_cmd() {
  local cmd=$1
  if command -v "$cmd" &>/dev/null; then
    return 0
  else
    echo "⛔️ $cmd is not available"
    return 1
  fi
}

prepare () {
  mkdir -p $CONF_DIR
  if [ -d $INSTALL_DIR ]; then
    read -p "Hooks are already present. Do you want to proceed? (Y/n)" choice
    read -p "" choice
    case "$choice" in
      n)
        exit 0
        ;;
      y | Y | "")
        echo "Continuing installation ..."
        rm -rf $INSTALL_DIR
        ;;
      *)
        echo "Unknown input. Aborting."
        exit 1
        ;;
    esac
  fi
}

download () {
  echo "Downloading ..."
  git clone --depth=1 --filter=tree:0 $REPO_URL $INSTALL_DIR
}

install_hook () {
  echo "Installing global hook ..."
  git config --global core.hooksPath $INSTALL_DIR/core/hooks
}

check_precommit () {
  # install pre-commit if needed
  if ! command -v pre-commit &>/dev/null; then
    if command -v brew &>/dev/null; then
      brew install pre-commit@v$PRE_COMMIT_VERSION
    elif command -v pip &>/dev/null; then
      pip install pre-commit@$PRE_COMMIT_VERSION
    fi
  else
    pc_version=$(pre-commit --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [[ ! "$pc_version" == "$PRE_COMMIT_VERSION" ]]; then
      # TODO
      echo "pre-commit version mismatch: $PRE_COMMIT_VERSION ≠ $pc_version"
    fi
  fi
}


check_cmd "python3"
check_cmd "docker"
prepare
download
install_hook
check_precommit



