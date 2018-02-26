#!/bin/bash
#set -xe

# gitlab-runner data directory
DATA_DIR="/etc/gitlab-runner"
CONFIG_FILE=${CONFIG_FILE:-$DATA_DIR/config.toml}
unregister_runner() {
  echo "unregistering runner"
  gitlab-runner unregister --all-runners
}

# custom certificate authority path
CA_CERTIFICATES_PATH=${CA_CERTIFICATES_PATH:-$DATA_DIR/certs/ca.crt}
LOCAL_CA_PATH="/usr/local/share/ca-certificates/ca.crt"
update_ca() {
  echo "Updating CA certificates..."
  cp "${CA_CERTIFICATES_PATH}" "${LOCAL_CA_PATH}"
  update-ca-certificates --fresh >/dev/null
}

if [ -f "${CA_CERTIFICATES_PATH}" ]; then
  # update the ca if the custom ca is different than the current
  cmp --silent "${CA_CERTIFICATES_PATH}" "${LOCAL_CA_PATH}" || update_ca
fi

# copy the ro config file that the helm chart provides into a
# file that can be modified
if [[ $CONFIG_FILE_RO != "" ]]; then
  if [ -f "${CONFIG_FILE_RO}"  ]; then
    cp $CONFIG_FILE_RO $CONFIG_FILE
  fi
fi

# Register the runner
if [[ $REGISTRATION_TOKEN != "" ]]; then
  trap unregister_runner HUP INT QUIT ABRT KILL ALRM TERM TSTP
  gitlab-runner register --non-interactive \
    --url $CI_SERVER_URL --executor $RUNNER_EXECUTOR "$@"
fi

# run the runner
gitlab-runner run "$@"