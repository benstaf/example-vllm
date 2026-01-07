
# ================================
# Base image (Koyeb GPU compatible)
# ================================
FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

# ================================
# Environment
# ================================
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1

# Default model & port (can be overridden in Koyeb UI)
ENV MODEL_NAME=benstaf/pitinf_8b_identity-merged
ENV PORT=8000

# ================================
# System dependencies
# ================================
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ================================
# Python dependencies
# ================================
RUN pip3 install --upgrade pip

# PyTorch CUDA 12.1
RUN pip3 install \
    torch==2.1.2 \
    torchvision==0.16.2 \
    torchaudio==2.1.2 \
    --index-url https://download.pytorch.org/whl/cu121

# vLLM + HF stack
RUN pip3 install \
    vllm \
    transformers \
    accelerate \
    huggingface_hub

# ================================
# Runtime
# ================================
EXPOSE 8000

CMD ["bash", "-lc", "\
echo '=== GPU INFO ===' && nvidia-smi && \
echo '=== STARTING vLLM OPENAI SERVER ===' && \
python3 -u -m vllm.entrypoints.openai.api_server \
  --model ${MODEL_NAME} \
  --host 0.0.0.0 \
  --port ${PORT} \
  --trust-remote-code \
  --gpu-memory-utilization 0.90 \
  --max-model-len 4096 \
  --distributed-executor-backend mp \
"]
