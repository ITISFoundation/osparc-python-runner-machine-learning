FROM nvidia/cuda:12.8.0-cudnn-runtime-ubuntu24.04 AS base

LABEL maintainer="Andrei Neagu <neagu@speag.swiss>"

ENV SC_USER_ID=8004
ENV SC_USER_NAME=scu
RUN adduser \
    --uid ${SC_USER_ID} \
    --disabled-password \
    --gecos "" \
    --shell /bin/sh --home /home/${SC_USER_NAME} ${SC_USER_NAME}

# Install uv tool
COPY --from=ghcr.io/astral-sh/uv:0.7.6 /uv /uvx /bin/
ENV UV_HTTP_TIMEOUT=120

# Install Python globally for all users
ARG PYTHON_VERSION=3.12.10
ENV UV_PYTHON_INSTALL_DIR=/opt/uv-python
RUN mkdir -p /opt/uv-python \
    && uv venv /opt/venv --python=python${PYTHON_VERSION%.*} \
    && chmod -R a+rx /opt/uv-python
ENV PATH="/opt/venv/bin:$PATH"

FROM base AS production

ENV SC_BUILD_TARGET=production
ENV SC_BOOT_MODE=production
ENV INPUT_FOLDER="/input" \
    OUTPUT_FOLDER="/output"
ENV PATH="/home/${SC_USER_NAME}/service.cli:${PATH}"

WORKDIR /home/${SC_USER_NAME}

COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} entrypoint.sh docker/
COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} main.py main.py

ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
RUN apt-get update \
    && apt-get install -y --no-install-recommends parallel \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "/bin/sh", "docker/entrypoint.sh", "/bin/sh", "-c" ]
CMD ["run"]

