#!/bin/bash
set -euo pipefail

export PATH="/home/${NB_USER}/.local/bin:${PATH}"

# Generate/refresh the landing notebook(s)
python /get_notebook.py

# Copy bundled notebooks into /import on first run
# (Don't chown here; the entrypoint already runs us as the correct UID/GID.)
if [ ! -f /import/home_page.ipynb ]; then
    # Copy only if there are any notebooks in the image
    shopt -s nullglob
    nb_files=(/home/"${NB_USER}"/*.ipynb)
    if [ ${#nb_files[@]} -gt 0 ]; then
        cp "${nb_files[@]}" /import/
    fi
    shopt -u nullglob
fi

# Trust notebooks (best-effort; don't fail the whole tool if trust fails)
jupyter trust /import/*.ipynb || true

# Start JupyterLab as the current user (should NOT be root with the new entrypoint)
exec jupyter lab --no-browser --ip=0.0.0.0 --port=8888