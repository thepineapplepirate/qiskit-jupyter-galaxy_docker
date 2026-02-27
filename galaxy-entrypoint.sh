#!/usr/bin/env bash
set -euo pipefail

TARGET_PATH="${_GALAXY_JOB_HOME_DIR:-$(pwd)}"
if [ ! -e "${TARGET_PATH}" ]; then
  TARGET_PATH="$(pwd)"
fi

TARGET_UID="$(stat -c %u "${TARGET_PATH}")"
TARGET_GID="$(stat -c %g "${TARGET_PATH}")"

echo "Galaxy entrypoint: target path ${TARGET_PATH} owned by UID=${TARGET_UID} GID=${TARGET_GID}"

# Ensure conda python is discoverable for the very first command in tool_script.sh
export PATH="/opt/conda/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

# If UID is 0, just run as root
if [ "${TARGET_UID}" -eq 0 ]; then
  echo "WARN: Detected UID 0 from ${TARGET_PATH}; running command as root."
  exec "$@"
fi

# Create matching group/user if needed
if ! getent group "${TARGET_GID}" >/dev/null 2>&1; then
  groupadd -g "${TARGET_GID}" gxgrp
fi

USERNAME="gxuser"
if id -u gxuser >/dev/null 2>&1; then
  EXISTING_UID="$(id -u gxuser)"
  if [ "${EXISTING_UID}" != "${TARGET_UID}" ]; then
    USERNAME="gxuser_${TARGET_UID}"
  fi
fi

if ! id -u "${USERNAME}" >/dev/null 2>&1; then
  useradd -m -u "${TARGET_UID}" -g "${TARGET_GID}" -s /bin/bash "${USERNAME}"
fi

# Make paths writable (tool XML writes into both)
chown -R "${TARGET_UID}:${TARGET_GID}" /home/jovyan || true
chmod -R u+rwX,g+rwX /home/jovyan || true

mkdir -p /import/jupyter /import/jupyter/outputs /import/jupyter/galaxy_inputs || true
chown -R "${TARGET_UID}:${TARGET_GID}" /import || true
chmod -R u+rwX,g+rwX /import || true

# Run preserving environment + argv exactly
exec gosu "${TARGET_UID}:${TARGET_GID}" "$@"