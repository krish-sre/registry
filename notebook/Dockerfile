# JupyterHub single-user notebook image: JupyterLab with git, boto3 and the AWS CLI.
# Published by .github/workflows/publish-notebook-image.yaml (manual trigger).
#
#   docker build -t ghcr.io/krish-sre/karo-notebook:dev notebook

FROM python:3.11-alpine AS builder

RUN apk add --no-cache build-base linux-headers

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --no-cache-dir --upgrade "pip>=26.1.2" "setuptools>=83" "wheel>=0.46.2"

# jupyterhub provides jupyterhub-singleuser; 5.x only warns when the Hub is 4.x.
RUN pip install --no-cache-dir \
    jupyterhub==5.5.2 \
    jupyterlab==4.6.4 \
    jupyterlab-git==0.54.0 \
    "boto3[crt]>=1.34.162" \
    "botocore[crt]>=1.34.162" \
    "awscli>=1.44.38" \
    "setuptools>=83" \
    "msgpack>=1.2.1"

# Hub-only web assets (incl. a vulnerable moment.js); the notebook server never serves them.
RUN rm -rf /opt/venv/share/jupyterhub/static

FROM python:3.11-alpine

RUN apk upgrade --no-cache \
    && apk add --no-cache bash git tini \
    && python -m pip uninstall -y pip setuptools wheel

# UID/GID match the chart's spawner.homeOwner default (1000:100).
RUN adduser -D -u 1000 -G users -s /bin/bash jovyan

# Owned by the notebook user so %pip install works without sudo.
COPY --from=builder --chown=1000:100 /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" \
    VIRTUAL_ENV="/opt/venv" \
    PYTHONUNBUFFERED=1

COPY jupyterlab_overrides.json /opt/venv/share/jupyter/lab/settings/overrides.json
COPY --chmod=0755 startup.sh /usr/local/bin/startup.sh

USER 1000:100
WORKDIR /home/jovyan
EXPOSE 8888

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/local/bin/startup.sh"]
