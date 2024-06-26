ARG PYTHON_VERSION=3.10
ARG BASE_IMAGE=python:${PYTHON_VERSION}-slim-bookworm
ARG VENV_PATH=/prod_venv

FROM ${BASE_IMAGE} AS builder

# Install Poetry
ARG POETRY_HOME=/opt/poetry
ARG POETRY_VERSION=1.7.1

# Install vllm
ARG VLLM_VERSION=0.5.0.post1

RUN apt-get update -y && apt-get install git gcc-12 g++-12 wget tar -y --no-install-recommends && apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 10 --slave /usr/bin/g++ g++ /usr/bin/g++-12


RUN wget https://github.com/vllm-project/vllm/archive/refs/tags/v${VLLM_VERSION}.tar.gz -O vllm.tar.gz && \
    tar -xzvp -f vllm.tar.gz

RUN python3 -m venv ${POETRY_HOME} && ${POETRY_HOME}/bin/pip3 install poetry==${POETRY_VERSION}
ENV PATH="$PATH:${POETRY_HOME}/bin"

# Activate virtual env
ARG VENV_PATH
ENV VIRTUAL_ENV=${VENV_PATH}
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"


COPY kserve/pyproject.toml kserve/poetry.lock kserve/
RUN --mount=type=cache,target=/root/.cache cd kserve && poetry install --no-root --no-interaction
COPY kserve kserve
RUN --mount=type=cache,target=/root/.cache cd kserve && poetry install --no-interaction

COPY huggingfaceserver/pyproject.toml huggingfaceserver/poetry.lock huggingfaceserver/
RUN --mount=type=cache,target=/root/.cache cd huggingfaceserver && poetry install --no-root --no-interaction
COPY huggingfaceserver huggingfaceserver
RUN --mount=type=cache,target=/root/.cache cd huggingfaceserver && poetry install --no-interaction

# Install vllm
RUN --mount=type=cache,target=/root/.cache cd vllm-${VLLM_VERSION} && pip install wheel packaging ninja setuptools>=49.4.0 && \
    pip install -v -r requirements-cpu.txt --extra-index-url https://download.pytorch.org/whl/cpu
# Performance boost for PyTorch in intel cpu
RUN --mount=type=cache,target=/root/.cache pip install https://intel-extension-for-pytorch.s3.amazonaws.com/ipex_dev/cpu/intel_extension_for_pytorch-2.3.100%2Bgit0eb3473-cp310-cp310-linux_x86_64.whl
RUN cd vllm-${VLLM_VERSION} && VLLM_TARGET_DEVICE=cpu python setup.py install


FROM ${BASE_IMAGE} AS prod

COPY third_party third_party

# For high performance memory allocation and better cache locality
RUN apt-get update -y && apt-get install libtcmalloc-minimal4 -y --no-install-recommends && apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    && echo 'export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4:$LD_PRELOAD' >> ~/.bashrc


# Activate virtual env
ARG VENV_PATH
ENV VIRTUAL_ENV=${VENV_PATH}
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN useradd kserve -m -u 1000 -d /home/kserve

COPY --from=builder --chown=kserve:kserve $VIRTUAL_ENV $VIRTUAL_ENV
COPY --from=builder kserve kserve
COPY --from=builder huggingfaceserver huggingfaceserver

# Set a writable Hugging Face home folder to avoid permission issue. See https://github.com/kserve/kserve/issues/3562
ENV HF_HOME="/tmp/huggingface"
# https://huggingface.co/docs/safetensors/en/speed#gpu-benchmark
ENV SAFETENSORS_FAST_GPU="1"
# https://huggingface.co/docs/huggingface_hub/en/package_reference/environment_variables#hfhubdisabletelemetry
ENV HF_HUB_DISABLE_TELEMETRY="1"

USER 1000
ENTRYPOINT ["python3", "-m", "huggingfaceserver"]

