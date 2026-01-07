# ---- Base CUDA image (Koyeb-compatible) ----
FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

# ---- System setup ----
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ---- Python deps ----
RUN pip3 install --upgrade pip

# Torch CUDA 12.1 wheels
RUN pip3 install \
    torch==2.1.2 \
    torchvision==0.16.2 \
    torchaudio==2.1.2 \
    --index-url https://download.pytorch.org/whl/cu121

# vLLM + HF
RUN pip3 install \
    vllm \
    transformers \
    accelerate \
    huggingface_hub

# ---- Default runtime env ----
ENV MODEL_NAME=benstaf/pitinf_8b_identity-merged
ENV PORT=8000

# ---- Expose API port ----
EXPOSE 8000

# ---- Start vLLM OpenAI server ----
CMD ["bash", "-lc", "\
echo '=== GPU INFO ===' && nvidia-smi && \
echo '=== STARTING vLLM ===' && \
python3 -u -m vllm.entrypoints.openai.api_server \
  --model ${MODEL_NAME} \
  --host 0.0.0.0 \
  --port ${PORT} \
  --trust-remote-code \
  --gpu-memory-utilization 0.90 \
  --max-model-len 4096 \
  --distributed-executor-backend mp \
  --log-level info \
"]
