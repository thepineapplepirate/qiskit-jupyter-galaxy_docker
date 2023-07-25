# GPU-enabled docker container with Jupyterlab and Qiskit.

[![bio.tools entry](https://img.shields.io/badge/bio.tools-gpu-enabled_docker_container_with_jupyterlab_for_ai.svg)](https://bio.tools/gpu-enabled_docker_container_with_jupyterlab_for_ai) [![RRID entry](https://img.shields.io/badge/RRID-SCR_022695-blue.svg)](https://scicrunch.org/resources/about/registry/SCR_022695)


## General information

Project name: An accessible infrastructure for quantum computing with Qiskit using a docker-based Jupyterlab in Galaxy.

Project home page: https://github.com/thepineapplepirate/qiskit-jupyter-galaxy.git, 

Docker file: https://raw.githubusercontent.com/thepineapplepirate/qiskit-jupyter-galaxy/main/Dockerfile

Container at Docker hub: https://hub.docker.com/r/thepineapplepirate/docker-qiskit-jupyter-galaxy (tag: latest)

Galaxy tool (that runs this container): https://github.com/usegalaxy-eu/galaxy/blob/release_22.01_europe/tools/interactive/interactivetool_ml_jupyter_notebook.xml

Data: This copies and imports most of Qiskit's tutorials and jupyter notebooks.

Operating system(s): Linux

Programming language(s): Python, Docker, XML

Other requirements: Docker 20.10.13, (Optional) CUDA 11.6, CUDA DNN 8

License: MIT License

RRID: [SCR_022695](https://scicrunch.org/resources/about/registry/SCR_022695)

bioToolsID: [gpu-enabled_docker_container_with_jupyterlab_for_ai](https://bio.tools/gpu-enabled_docker_container_with_jupyterlab_for_ai)


## Running steps:

1. Download container: `docker pull thepineapplepirate/docker-qiskit-jupyter-galaxy:latest`

2. Run container (on host without Nvidia GPU): `docker run -it -p 8888:8888 -v <<path to local folder>>:/import thepineapplepirate/docker-qiskit-jupyter-galaxy:latest`

3. Run container (on host with Nvidia GPU): `docker run -it --gpus all -p 8888:8888 -v <<path to local folder>>:/import thepineapplepirate/docker-qiskit-jupyter-galaxy:latest`

4. Open the link to the Jupyterlab (e.g. `http://<<host>>:8888/ipython/lab`)

## List of packages

- Python (version: 3.9.7)
- Jupyterlab (version: 3.3.2)
- Jupyterlab-git (version: 0.36.0)
- Scikit learn (version: 1.0.1)
- Scikit image (version: 0.18.3)
- ONNX (version: 1.11.0)
- Nibabel (3.2.2)
- OpenCV (version: 4.5.5)
- CUDA (version: 11.7)
- CUDA DNN (version: 8)
- Bqplot (version: 0.12.33)
- Bokeh (version: 2.3.3)
- Matplotlib (version: 3.1.3)
- Seaborn (version: 0.11.2)
- Voila (version: 0.3.5)
- Jupyterlab-nvdashboard (version: 0.6.0)
- Py3Dmol (version: 1.8.0)
- Colabfold (version: 1.2.0)
- Bioblend (version: 0.16.0)
- Biopython (version: 1.79)
- many more ...
