FROM simcore/services/comp/common:0.0.0 AS service-base

LABEL maintainer="Andrei Neagu <neagu@speag.swiss>"

COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} service.cli/ service.cli/
COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} osparc_python_runner_tensorflow osparc_python_runner_tensorflow
RUN mv main.py osparc_python_runner_tensorflow/main.py

RUN uv pip install -r osparc_python_runner_tensorflow/requirements.txt