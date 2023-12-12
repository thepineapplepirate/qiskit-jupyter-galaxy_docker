# GPU-enabled docker container with Jupyterlab and Qiskit.

## General information

Project name: An accessible infrastructure for quantum computing with Qiskit using a docker-based Jupyterlab in Galaxy.

Project home page: https://github.com/thepineapplepirate/qiskit-jupyter-galaxy_docker.git, 

**Originally forked from: https://github.com/anuprulez/ml-jupyter-notebook.git**

Docker file: https://raw.githubusercontent.com/thepineapplepirate/qiskit-jupyter-galaxy_docker/main/Dockerfile

Container at Docker hub: https://hub.docker.com/r/thepineapplepirate/qiskit_galaxy (tag: 1.0.0)

Data: This copies and imports most of Qiskit's tutorials and jupyter notebooks.

Operating system(s): Linux

Programming language(s): Python, Docker, XML

Other requirements: Docker 20.10.13, (Optional) CUDA 11.6, CUDA DNN 8

License: MIT License


## Running steps:

1. Download container: `docker pull thepineapplepirate/qiskit_galaxy:1.0.0`

2. Run container (on host without Nvidia GPU): `docker run -it -p 8888:8888 -v <<path to local folder>>:/import thepineapplepirate/qiskit_galaxy:1.0.0`

3. Run container (on host with Nvidia GPU): `docker run -it --gpus all -p 8888:8888 -v <<path to local folder>>:/import thepineapplepirate/qiskit_galaxy:1.0.0`

4. Open the link to the Jupyterlab (e.g. `http://<<host>>:8888/ipython/lab`)

## List of packages

- Python 
- Jupyterlab 
- Jupyterlab-git 
- CUDA 
- CUDA DNN 
- Bqplot 
- Bokeh 
- Voila 
- Numpy
- Jupyterlab-nvdashboard 
- Bioblend 
- Qiskit (all) and Qiskit-research
- many more ...
