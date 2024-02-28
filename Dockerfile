## Jupyter container used for Data Science
##shikaka rules!
FROM jupyter/scipy-notebook:2022-02-17

LABEL maintainer="Blankenberg Lab"

ENV DEBIAN_FRONTEND noninteractive

USER root 

RUN apt-get -qq update && apt-get upgrade -y && apt-get install --no-install-recommends -y libcurl4-openssl-dev libxml2-dev \
    apt-transport-https python3-dev python3-pip libc-dev pandoc pkg-config liblzma-dev libbz2-dev libpcre3-dev \
    build-essential libblas-dev liblapack-dev libzmq3-dev libyaml-dev libxrender1 fonts-dejavu \
    libfreetype6-dev libpng-dev net-tools procps libreadline-dev wget software-properties-common gnupg2 curl ca-certificates && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install CUDA Toolkit and CuDNN
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
RUN mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600

RUN wget "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb" && dpkg -i cuda-keyring_1.0-1_all.deb && rm cuda-keyring_1.0-1_all.deb
RUN add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
RUN apt-get update
RUN apt-get -y install cuda
RUN apt-get -y install libcudnn8

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
    xeus-python \
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

RUN pip install numpy==1.20.0

## Qiskit block 
## INSTALL standard qiskit pypi packages
RUN pip install 'qiskit[all]'

## INSTALL qiskit research
RUN git clone https://github.com/qiskit-research/qiskit-research.git && cd qiskit-research && pip install .

## INSTALL xyz2pdb
RUN pip install qiskit-xyz2pdb 

## Add new alternative to IBMQ
RUN pip install qiskit-ibm-provider

## COPY all the tutorial files and accessory files
RUN mkdir -p /home/$NB_USER/qiskit \
    && curl -L https://github.com/Qiskit/platypus/tarball/master | tar -xz --directory /home/$NB_USER/qiskit/ && mv /home/$NB_USER/qiskit/Qiskit-platypus* /home/$NB_USER/qiskit/platypus \
    && curl -L https://github.com/Qiskit/qiskit-tutorials/tarball/master | tar -xz --directory /home/$NB_USER/qiskit/ && mv /home/$NB_USER/qiskit/Qiskit-qiskit-tutorials* /home/$NB_USER/qiskit/qiskit-tutorials \
    && curl -L https://github.com/qiskit-community/qiskit-community-tutorials/tarball/master | tar -xz --directory /home/$NB_USER/qiskit/ && mv /home/$NB_USER/qiskit/qiskit-community-qiskit-community-tutorials* /home/$NB_USER/qiskit/qiskit-community-tutorials \
    && curl -L https://github.com/qiskit-community/qiskit-textbook/tarball/master | tar -xz --directory /home/$NB_USER/qiskit/ && mv /home/$NB_USER/qiskit/qiskit-community-qiskit-textbook* /home/$NB_USER/qiskit/qiskit-textbook \
    && curl -L https://github.com/qiskit-community/qiskit-pocket-guide/tarball/master | tar -xz --directory /home/$NB_USER/qiskit/ && mv /home/$NB_USER/qiskit/qiskit-community-qiskit-pocket-guide* /home/$NB_USER/qiskit/qiskit-pocket-guide

## Add the protein folding notebook version from qiskit-research
RUN curl -L https://raw.githubusercontent.com/qiskit-community/qiskit-research/main/docs/protein_folding/protein_folding.ipynb > /home/$NB_USER/qiskit/qiskit-tutorials/tutorials/algorithms/protein_folding.ipynb
## End Qiskit Block

RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 

RUN conda --version

RUN conda install -y -q -c conda-forge -c bioconda kalign2=2.04 hhsuite=3.3.0

ADD ./startup.sh /startup.sh
ADD ./get_notebook.py /get_notebook.py

RUN mkdir -p /home/$NB_USER/.ipython/profile_default/startup/
RUN mkdir /import

COPY ./galaxy_script_job.py /home/$NB_USER/.ipython/profile_default/startup/00-load.py
COPY ./ipython-profile.py /home/$NB_USER/.ipython/profile_default/startup/01-load.py
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

RUN chown -R $NB_USER:users /home/$NB_USER /import

WORKDIR /import

CMD /startup.sh
