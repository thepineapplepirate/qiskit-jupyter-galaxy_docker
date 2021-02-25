# Jupyter container used for Tensorflow
FROM jupyter/tensorflow-notebook:latest

MAINTAINER Anup Kumar, anup.rulez@gmail.com

ENV DEBIAN_FRONTEND noninteractive

# Install system libraries first as root
USER root

ENV CUDA_VERSION 11.0.3 

ENV CUDA_RT 11.0.221

ENV CUDA_PKG_VERSION 11-0=$CUDA_RT-1  

ENV CUDNN_VERSION 8.0.5.39 

ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda-10.2/lib64:/usr/local/cuda-10.1/lib64//usr/local/cuda-11.0/lib64:$LD_LIBRARY_PATH

ENV NVIDIA_VISIBLE_DEVICES=all

ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# Package location Ubuntu 20.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64/ /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/*

# Install CUDA
RUN apt-get update && apt-get install -y --no-install-recommends \
     cuda-11-0 \
     cuda-cudart-$CUDA_PKG_VERSION && \
     ln -s cuda-11.0 /usr/local/cuda && \
     rm -rf /var/lib/apt/lists/*

# Install cuDNN
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcudnn8=$CUDNN_VERSION-1+cuda11.0 \
    libcudnn8-dev=$CUDNN_VERSION-1+cuda11.0 && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

# Python packages
RUN pip install --no-cache-dir tensorflow-gpu==2.4.1 onnx onnx-tf
# tf2onn

ADD ./startup.sh /startup.sh

USER root

RUN mkdir -p /home/$NB_USER/.ipython/profile_default/startup/
RUN mkdir /import

#COPY ./ipython-profile.py /home/$NB_USER/.ipython/profile_default/startup/00-load.py
#COPY jupyter_notebook_config.py /home/$NB_USER/.jupyter/
#ADD ./default_notebook_ml.ipynb /home/$NB_USER/tensorflow_notebook.ipynb

COPY ./ipython-profile.py /home/$NB_USER/.ipython/profile_default/startup/00-load.py
COPY ./jupyter_notebook_config.py /home/$NB_USER/.jupyter/
ADD ./default_notebook_ml.ipynb /home/$NB_USER/tensorflow_notebook.ipynb

RUN mkdir -p /home/$NB_USER/.jupyter/custom/

#ADD ./custom.js /home/$NB_USER/.jupyter/custom/custom.js
#ADD ./useGalaxyeu.svg /home/$NB_USER/.jupyter/custom/useGalaxyeu.svg
#ADD ./custom.css /home/$NB_USER/.jupyter/custom/custom.css

RUN mkdir -p /home/$NB_USER/.jupyter/custom/

ADD ./custom.js /home/$NB_USER/.jupyter/custom/custom.js
ADD ./useGalaxyeu.svg /home/$NB_USER/.jupyter/custom/useGalaxyeu.svg
ADD ./custom.css /home/$NB_USER/.jupyter/custom/custom.css

# ENV variables to replace conf file
ENV DEBUG=false \
    GALAXY_WEB_PORT=10000 \
    NOTEBOOK_PASSWORD=none \
    CORS_ORIGIN=none \
    DOCKER_PORT=none \
    API_KEY=none \
    HISTORY_ID=none \
    REMOTE_HOST=none \
    GALAXY_URL=none

RUN mkdir /export/ && chown -R $NB_USER:users /home/$NB_USER /import /export/

WORKDIR /import

CMD /startup.sh
