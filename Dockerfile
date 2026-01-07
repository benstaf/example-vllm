FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# System deps
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Python deps
RUN pip3 install --upgrade pip

# vLLM + HF
RUN pip3 install \
    vllm \
    torch \
    transformers \
    accelerate \
    safetensors \
    huggingface_hub

# Default model (no env var needed)
ENV MODEL_NAME=benstaf/pitinf_8b_identity-merged
ENV PORT=8000

EXPOSE 8000

# vLLM OpenAI-compatible server
CMD python3 -m vllm.entrypoints.openai.api_server \
    --model ${MODEL_NAME} \
    --host 0.0.0.0 \
    --port ${PORT} \
    --trust-remote-code
