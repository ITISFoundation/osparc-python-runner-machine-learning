FROM nvidia/cuda:12.8.0-cudnn-runtime-ubuntu24.04 AS base

LABEL maintainer="Andrei Neagu <neagu@speag.swiss>"

ENV SC_USER_ID=8004
ENV SC_USER_NAME=scu

RUN adduser \
    --uid ${SC_USER_ID} \
    --disabled-password \
    --gecos "" \
    --shell /bin/sh --home /home/${SC_USER_NAME} ${SC_USER_NAME}

RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    jq \
    libbz2-dev \
    libffi-dev \
    liblzma-dev \
    libncurses5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxmlsec1-dev \
    llvm \
    make \
    python3-minimal \
    python3-pip \
    python3-venv \
    tk-dev \
    wget \
    xz-utils \
    zlib1g-dev \
    && rm --recursive --force /var/lib/apt/lists/* 

COPY --from=ghcr.io/astral-sh/uv:0.7.6 /uv /uvx /bin/

FROM base AS production

ENV SC_BUILD_TARGET=production
ENV SC_BOOT_MODE=production
ENV INPUT_FOLDER="/input" \
    OUTPUT_FOLDER="/output"
ENV PATH="/home/${SC_USER_NAME}/service.cli:${PATH}"

WORKDIR /home/${SC_USER_NAME}

# copy docker bootup scripts
COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} entrypoint.sh docker/

# copy main.py
COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} main.py main.py

ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# installing python via pyenv and setting it as default
# NOTE: make sure the same version of python is used when running make requirements
ARG PYTHON_VERSION=3.12.10
ENV PYENV_ROOT=/home/${SC_USER_NAME}/.pyenv
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
RUN git clone https://github.com/pyenv/pyenv.git /home/${SC_USER_NAME}/.pyenv && \
    git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv && \
    pyenv install ${PYTHON_VERSION} && \
    pyenv global ${PYTHON_VERSION}

ENTRYPOINT [ "/bin/sh", "docker/entrypoint.sh", "/bin/sh", "-c" ]
CMD ["run"]

