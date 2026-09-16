## Jupyter container used for Data Science
FROM quay.io/jupyter/scipy-notebook:x86_64-python-3.12

LABEL maintainer="Blankenberg Lab"

ENV DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get -qq update && apt-get upgrade -y && apt-get install --no-install-recommends -y \
    libcurl4-openssl-dev libxml2-dev apt-transport-https python3-dev python3-pip libc-dev \
    pandoc pkg-config liblzma-dev libbz2-dev libpcre3-dev build-essential libblas-dev \
    liblapack-dev libzmq3-dev libyaml-dev libxrender1 fonts-dejavu libfreetype6-dev \
    libpng-dev net-tools procps libreadline-dev wget software-properties-common gnupg2 \
    curl ca-certificates && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install gosu for clean UID/GID dropping and ensure python shim exists
RUN apt-get update && apt-get install -y --no-install-recommends gosu && \
    ln -sf /opt/conda/bin/python /usr/local/bin/python && \
    rm -rf /var/lib/apt/lists/*

# Install CUDA Toolkit and CuDNN
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb \
    -o /tmp/cuda-keyring.deb && \
    dpkg -i /tmp/cuda-keyring.deb && \
    rm -f /tmp/cuda-keyring.deb

RUN apt-get update && \
    apt-get install -y --no-install-recommends cuda-toolkit-12-6 && \
    rm -rf /var/lib/apt/lists/*

# Python packages
RUN pip install --no-cache-dir \
    bioblend \
    galaxy-ie-helpers \
    jupyterlab-git \
    jupyter_server \
    jupyterlab \
    jupytext \
    jupyterlab-kernelspy \
    jupyterlab-fasta \
    jupyterlab-geojson \
    jupyter_bokeh \
    bqplot

RUN pip install --no-cache-dir voila

## Shared Qiskit/protein-folding stack
# The build context is the parent Desktop/gitrepos directory. These COPY
# paths intentionally use local checkouts so this image can be tested before
# the modernization branches are published to PyPI.
COPY QBioCode /opt/src/QBioCode
COPY QTF /opt/src/QTF
COPY pheat /opt/src/pheat
COPY quantum-protein-folding-fcc /opt/src/quantum-protein-folding-fcc
COPY quantum-protein-folding-tetrahedral /opt/src/quantum-protein-folding-tetrahedral

RUN set -eux; \
    python -m pip install --no-cache-dir --upgrade pip; \
    python -m pip install --no-cache-dir \
      -r /opt/src/QBioCode/requirements.txt \
      'ray>=2.47,<3' \
      'mdtraj>=1.9' \
      'biopython>=1.80'; \
    python -m pip install --no-cache-dir /opt/src/pheat; \
    python -m pip install --no-cache-dir /opt/src/QBioCode; \
    python -m pip install --no-cache-dir /opt/src/quantum-protein-folding-fcc; \
    python -m pip install --no-cache-dir /opt/src/quantum-protein-folding-tetrahedral; \
    python -m pip install --no-cache-dir '/opt/src/QTF[workflows,notebook]'; \
    rm -rf /opt/src/*/*.egg-info /opt/src/*/*/*.egg-info || true

# QTF and the modern prebuilt extensions target JupyterLab 4. Keep the core
# and extension ABI aligned after all domain packages resolve dependencies.
RUN python -m pip install --no-cache-dir --upgrade \
    'jupyterlab>=4.4,<5' \
    'notebook>=7,<8' && \
    python -m pip uninstall -y \
      jupyterlab-nvdashboard \
      jupyterlab-system-monitor \
      jupyterlab-topbar \
      jupyterlab-execute-time \
      lckr-jupyterlab-variableinspector \
      jupyter-resource-usage || true

# qiskit-ibm-transpiler 0.18 requires NetworkX 2.8.5. Keep the inherited
# scikit-image package compatible with that constraint.
RUN python -m pip install --no-cache-dir 'scikit-image<0.25'

RUN conda --version
# The Jupyter base image includes mamba; use it here because the classic
# conda solver can misparse the BLAS metapackage while solving this mix.
RUN mamba install -y -q -c conda-forge -c bioconda \
    kalign2=2.04 hhsuite=3.3.0 'gromacs>=2026'

RUN set -eux; \
    mkdir -p "/home/$NB_USER/Biophysics/Lattice Models/FCC Lattice Models"; \
    mkdir -p "/home/$NB_USER/Biophysics/Lattice Models/Tetrahedral"; \
    mkdir -p "/home/$NB_USER/Biophysics/Continuous Space Models/QTF"; \
    mkdir -p "/home/$NB_USER/Quantum Machine Learning"; \
    cp /opt/src/quantum-protein-folding-fcc/workflow_demo.ipynb "/home/$NB_USER/Biophysics/Lattice Models/FCC Lattice Models/"; \
    cp /opt/src/quantum-protein-folding-tetrahedral/docs/protein_folding_qiskit2.ipynb "/home/$NB_USER/Biophysics/Lattice Models/Tetrahedral/"; \
    cp /opt/src/QTF/QTF.ipynb "/home/$NB_USER/Biophysics/Continuous Space Models/QTF/"; \
    cp -a /opt/src/QBioCode/tutorial "/home/$NB_USER/Quantum Machine Learning/QBioCode"; \
    cp -a /opt/src/QBioCode/docs/_build "/home/$NB_USER/Quantum Machine Learning/QBioCode/"; \
    chown -R $NB_USER:users "/home/$NB_USER/Biophysics" "/home/$NB_USER/Quantum Machine Learning" /opt/src

# Ensure "python" is always resolvable even if PATH gets weird
RUN ln -sf /opt/conda/bin/python /usr/local/bin/python

ADD qiskit-jupyter-galaxy_docker/startup.sh /startup.sh
ADD qiskit-jupyter-galaxy_docker/get_notebook.py /get_notebook.py

RUN mkdir -p /home/$NB_USER/.ipython/profile_default/startup/
RUN mkdir -p /import

COPY qiskit-jupyter-galaxy_docker/galaxy_script_job.py /home/$NB_USER/.ipython/profile_default/startup/00-load.py
COPY qiskit-jupyter-galaxy_docker/ipython-profile.py   /home/$NB_USER/.ipython/profile_default/startup/01-load.py
COPY qiskit-jupyter-galaxy_docker/jupyter_server_config.py /home/$NB_USER/.jupyter/jupyter_server_config.py

# ENV variables to replace conf file
ENV DEBUG=false \
    GALAXY_WEB_PORT=10000 \
    NOTEBOOK_PASSWORD=none \
    CORS_ORIGIN=none \
    DOCKER_PORT=none \
    API_KEY=none \
    HISTORY_ID=none \
    REMOTE_HOST=none \
    DISABLE_AUTH=true \
    GALAXY_URL=none

# Make local (non-bind-mounted) paths sane.
# NOTE: /import is bind-mounted by Galaxy at runtime, so build-time perms won't override the mount.
RUN mkdir -p /export/ && \
    chown -R $NB_USER:users /home/$NB_USER/ /export/ && \
    chmod -R u+rwX,g+rwX /home/$NB_USER/ /export/

# --- NEW: Galaxy-aware entrypoint ---
COPY qiskit-jupyter-galaxy_docker/galaxy-entrypoint.sh /usr/local/bin/galaxy-entrypoint.sh
RUN chmod +x /usr/local/bin/galaxy-entrypoint.sh

WORKDIR /import

# The upstream notebook image checks Jupyter every three seconds with a
# one-second timeout. Under amd64 emulation on Apple Silicon those timed-out
# probes can remain alive and eventually starve kernels and terminals. Galaxy
# already owns interactive-tool lifecycle/readiness, so do not inherit it.
HEALTHCHECK NONE

ENTRYPOINT ["/usr/local/bin/galaxy-entrypoint.sh"]
CMD ["/startup.sh"]
