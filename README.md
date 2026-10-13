# registry

Public JupyterHub notebook image for the KARO standalone Helm chart.

`ghcr.io/krish-sre/karo-notebook` is a single-user server image based on
`python:3.11-alpine` with:

- JupyterHub 5.5.2 (`jupyterhub-singleuser`) and JupyterLab 4.6.4
- `jupyterlab-git` and the `git` CLI
- `boto3` and the AWS CLI v1
- user `jovyan`, UID/GID `1000:100`, home `/home/jovyan`

There is no `sudo`; `%pip install` works because the Python environment is
owned by the notebook user.

## Pull

```bash
docker pull ghcr.io/krish-sre/karo-notebook:<version>
```

Available versions are listed under **Packages** on this repository.

## Try it locally

The default command expects a JupyterHub. To run JupyterLab on its own:

```bash
docker run --rm -p 8888:8888 --entrypoint jupyter \
  ghcr.io/krish-sre/karo-notebook:<version> lab --ip=0.0.0.0 --no-browser
```

Open the `http://127.0.0.1:8888/lab?token=...` URL printed in the log.

## Use with the standalone Helm chart

Override the notebook image in your values file:

```yaml
spawner:
  image:
    repository: ghcr.io/krish-sre/karo-notebook
    tag: "<version>"
  cmd: ["/usr/local/bin/startup.sh"]
  homeOwner: "1000:100"
```

```bash
helm upgrade --install karo ./helm-standalone -n <namespace> -f my-values.yaml
```

The image is public, so no `imagePullSecrets` are needed. Running notebook
servers keep their old image until they are restarted.

## Build locally

```bash
docker build -t karo-notebook:dev notebook
```

## Publish a new version

Publishing is manual only:

1. Open **Actions → Publish Notebook Image → Run workflow**.
2. Enter a version such as `1.0.1`; tick **also_tag_latest** if wanted.

The workflow pushes `ghcr.io/krish-sre/karo-notebook:<version>` using the
built-in `GITHUB_TOKEN` and prints a Trivy report (HIGH/CRITICAL, informational).

After the first publish, set the package visibility to **Public** once under
**Packages → karo-notebook → Package settings**. New GHCR packages start private.
