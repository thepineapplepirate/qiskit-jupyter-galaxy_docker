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
    lckr-jupyterlab-variableinspector \
    jupyterlab_execute_time \
    jupyterlab-kernelspy \
    jupyterlab-system-monitor \
    jupyterlab-fasta \
    jupyterlab-geojson \
    jupyterlab-topbar \
    jupyter_bokeh \
    jupyterlab_nvdashboard \
    bqplot \
    aquirdturtle_collapsible_headings

RUN pip install --no-cache-dir voila

## Qiskit block
RUN set -eux; \
    mkdir -p /home/$NB_USER; \
    git clone --depth 1 https://github.com/IBM/QBioCode.git /home/$NB_USER/QBioCode; \
    pip install /home/$NB_USER/QBioCode; \
    pip install "/home/$NB_USER/QBioCode[apps]"; \
    rm -rf /home/$NB_USER/QBioCode/*.egg-info /home/$NB_USER/QBioCode/*/*.egg-info || true; \
    mkdir -p /import/jupyter; \
    ln -sf /home/$NB_USER/QBioCode /import/jupyter/QBioCode; \
    chown -R $NB_USER:users /home/$NB_USER/QBioCode /import/jupyter/QBioCode || true

RUN set -eux; \
    mkdir -p /home/$NB_USER/qiskit; \
    mkdir -p /home/$NB_USER/qiskit/platypus; \
    curl -fsSL https://github.com/Qiskit/platypus/tarball/HEAD \
      | tar -xz --strip-components=1 --directory /home/$NB_USER/qiskit/platypus; \
    mkdir -p /home/$NB_USER/qiskit/qiskit-tutorials; \
    curl -fsSL https://github.com/Qiskit/qiskit-tutorials/tarball/HEAD \
      | tar -xz --strip-components=1 --directory /home/$NB_USER/qiskit/qiskit-tutorials; \
    mkdir -p /home/$NB_USER/qiskit/qiskit-community-tutorials; \
    curl -fsSL https://github.com/qiskit-community/qiskit-community-tutorials/tarball/HEAD \
      | tar -xz --strip-components=1 --directory /home/$NB_USER/qiskit/qiskit-community-tutorials; \
    mkdir -p /home/$NB_USER/qiskit/qiskit-textbook; \
    curl -fsSL https://github.com/qiskit-community/qiskit-textbook/tarball/HEAD \
      | tar -xz --strip-components=1 --directory /home/$NB_USER/qiskit/qiskit-textbook; \
    mkdir -p /home/$NB_USER/qiskit/qiskit-pocket-guide; \
    curl -fsSL https://github.com/qiskit-community/qiskit-pocket-guide/tarball/HEAD \
      | tar -xz --strip-components=1 --directory /home/$NB_USER/qiskit/qiskit-pocket-guide; \
    chown -R $NB_USER:users /home/$NB_USER/qiskit || true

RUN pip install --no-cache-dir \
    pylatexenc \
    matplotlib==3.8.3 \
    numpy==1.26.4 \
    h5py==3.11.0 \
    hfda==0.1.1 \
    hydra-core==1.3.2 \
    ipykernel==6.29.5 \
    networkx==3.2.1 \
    pandas==2.2.2

RUN conda --version
RUN conda install -y -q -c conda-forge -c bioconda kalign2=2.04 hhsuite=3.3.0

# Ensure "python" is always resolvable even if PATH gets weird
RUN ln -sf /opt/conda/bin/python /usr/local/bin/python

ADD ./startup.sh /startup.sh
ADD ./get_notebook.py /get_notebook.py

RUN mkdir -p /home/$NB_USER/.ipython/profile_default/startup/
RUN mkdir -p /import

COPY ./galaxy_script_job.py /home/$NB_USER/.ipython/profile_default/startup/00-load.py
COPY ./ipython-profile.py   /home/$NB_USER/.ipython/profile_default/startup/01-load.py
COPY ./jupyter_server_config.py /home/$NB_USER/.jupyter/jupyter_server_config.py

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
COPY ./galaxy-entrypoint.sh /usr/local/bin/galaxy-entrypoint.sh
RUN chmod +x /usr/local/bin/galaxy-entrypoint.sh

WORKDIR /import

ENTRYPOINT ["/usr/local/bin/galaxy-entrypoint.sh"]
CMD ["/startup.sh"]