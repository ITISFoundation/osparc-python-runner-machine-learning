FROM nvidia/cuda:12.8.0-cudnn-runtime-ubuntu24.04 AS base

LABEL maintainer="Andrei Neagu <neagu@speag.swiss>"

ENV SC_USER_ID=8004
ENV SC_USER_NAME=scu

RUN adduser \
    --uid ${SC_USER_ID} \
    --disabled-password \
    --gecos "" \
    --shell /bin/sh --home /home/${SC_USER_NAME} ${SC_USER_NAME}

COPY --from=ghcr.io/astral-sh/uv:0.7.6 /uv /uvx /bin/

# installing python and setting as default also creating a default system wide venv
# NOTE: make sure the same version of python is used when running make requirements
ARG PYTHON_VERSION=3.12.10
RUN uv python install ${PYTHON_VERSION} --default --preview && \
    uv venv .venv
ENV PATH="/home/${SC_USER_NAME}/.venv/bin:$PATH"

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


ENTRYPOINT [ "/bin/sh", "docker/entrypoint.sh", "/bin/sh", "-c" ]
CMD ["run"]

