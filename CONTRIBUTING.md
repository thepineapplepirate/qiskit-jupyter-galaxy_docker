# Contributing

1. Fork this repository and create a feature branch.
2. Clone the QBioCode, QTF, PHeat, FCC, and tetrahedral repositories beside
   this repository, using the directory layout documented in `README.md`.
3. Build the image from the common parent directory.
4. Smoke-test a terminal, a blank Python notebook, and each bundled workflow.
5. Open a pull request describing dependency, image-layout, and Galaxy-tool
   changes.

An amd64 Linux host is recommended for full builds and notebook execution.
Apple Silicon is suitable for UI and Galaxy integration work through amd64
emulation, but it is significantly slower.

Do not commit credentials, API keys, generated build outputs, or local absolute
symlinks. Runtime credentials are supplied by Galaxy.

## Publishing an image

After validation, tag and push the image explicitly:

```bash
docker push thepineapplepirate/qiskit_galaxy:2.1.0
```

Publishing requires authorization for the Docker Hub repository and is
separate from merging a source-code pull request.

## Contributors

- [ThePineapplePirate](https://github.com/thepineapplepirate)
- [Dan Blankenberg](https://github.com/blankenberg)
