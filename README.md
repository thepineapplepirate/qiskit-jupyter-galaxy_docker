# Qiskit JupyterLab for Galaxy

GPU-capable JupyterLab image and Galaxy interactive-tool definition for quantum
biology and protein-folding workflows.

The `2.1.0` image contains:

- QBioCode
- QTF and PHeat
- FCC and tetrahedral protein-folding models
- Qiskit and the supporting scientific Python stack
- JupyterLab 4 and Notebook 7
- GROMACS, HH-suite, and Kalign
- CUDA 12.6 tooling for compatible Linux GPU hosts

User-facing notebooks are organized under `Biophysics` and
`Quantum Machine Learning`. Complete local repository checkouts are copied into
`/opt/src` and installed into the container's Conda environment.

## Build

The Docker build context must be the parent directory containing these sibling
checkouts:

```text
gitrepos/
├── QBioCode/
├── QTF/
├── pheat/
├── quantum-protein-folding-fcc/
├── quantum-protein-folding-tetrahedral/
└── qiskit-jupyter-galaxy_docker/
```

Use these branches when assembling the build context:

| Checkout | Branch |
| --- | --- |
| `QBioCode` | `qiskit-stack-modernization` |
| `QTF` | `main` |
| `pheat` | `main` |
| `quantum-protein-folding-fcc` | `qiskit-2-modernization` |
| `quantum-protein-folding-tetrahedral` | `main` |
| `qiskit-jupyter-galaxy_docker` | `main` (or the branch under review) |

The FCC checkout installs the `fcc` Python package. The tetrahedral checkout
installs `protein_folding`. The legacy local `qufold` implementation is not a
build input.

From `gitrepos`:

```bash
docker build \
  --platform linux/amd64 \
  -f qiskit-jupyter-galaxy_docker/Dockerfile \
  -t thepineapplepirate/qiskit_galaxy:2.1.0 \
  .
```

The image is large because it includes CUDA, PyTorch, GROMACS, and the complete
scientific stack. Building and running it on an amd64 Linux host is recommended.
Apple Silicon can use amd64 emulation for integration testing, but builds and
notebook startup are substantially slower.

## Standalone smoke test

```bash
mkdir -p /tmp/qiskit-jupyter/import

docker run --rm \
  --platform linux/amd64 \
  -p 8888:8888 \
  -v /tmp/qiskit-jupyter/import:/import \
  thepineapplepirate/qiskit_galaxy:2.1.0
```

Open `http://localhost:8888/ipython/lab`.

On a compatible NVIDIA Linux host, add `--gpus all` to `docker run`.

## Galaxy integration

Install `interactivetool_qiskit_jupyter_notebook.xml` and
`default_notebook.ipynb` together in Galaxy's interactive-tool directory. The
tool definition launches image tag `2.1.0` and exposes the curated notebook
directories inside Galaxy's `/import/jupyter` working directory.

The container image does not define a Docker health check. Galaxy manages the
interactive-tool lifecycle and readiness; disabling the upstream one-second
probe also prevents process accumulation under amd64 emulation.

## Container registry

Published images are available at
[Docker Hub](https://hub.docker.com/r/thepineapplepirate/qiskit_galaxy).

## License

This repository is licensed under the terms in [LICENSE.md](LICENSE.md).
