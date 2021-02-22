#!/usr/bin/env bash

set -euEo pipefail

set -o allexport
. "${WORKDIR}/.env"
set +o allexport

export DEBIAN_FRONTEND=noninteractive

readonly text="export LIBS_DIR=/usr/local/lib"
readonly file="/home/${USER_NAME}/.bashrc"

if ! grep -q "$text" "$file"; then
  echo "$text" >>"$file"
  chown "${USER_NAME}:${USER_NAME}" "$file"
fi

apt-get update -y
apt-get install -y git shellcheck build-essential

cd /tmp/
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
cd /tmp/
rm -r /tmp/bats-core
git clone https://github.com/bats-core/bats-assert.git /usr/local/lib/bats-assert
git clone https://github.com/bats-core/bats-support.git /usr/local/lib/bats-support
