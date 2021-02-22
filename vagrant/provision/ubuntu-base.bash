#!/usr/bin/env bash

set -euEo pipefail

set -o allexport
. "${WORKDIR}/.env"
set +o allexport

export DEBIAN_FRONTEND=noninteractive

# System update
apt-get update -y

# User
echo "${USER_NAME} ALL=NOPASSWD:ALL" >/etc/sudoers.d/nopasswd

if ! getent passwd | grep --quiet "$USER_NAME"; then
  useradd --create-home --shell /bin/bash "$USER_NAME"
  usermod -aG sudo "$USER_NAME"
fi

readonly text="cd ${WORKDIR}"
readonly file="/home/${USER_NAME}/.bashrc"

if ! grep -q "$text" "$file"; then
  echo "$text" >>"$file"
  chown "${USER_NAME}:${USER_NAME}" "$file"
fi
