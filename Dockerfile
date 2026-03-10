FROM python:3.10-slim
WORKDIR /app

# Install only what's needed
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install CPU-only torch (saves ~1.5GB vs full torch)
RUN pip install --no-cache-dir \
    torch --index-url https://download.pytorch.org/whl/cpu

RUN pip install --no-cache-dir -r requirements.txt

ENV HF_HOME=/tmp
ENV TRANSFORMERS_CACHE=/tmp

RUN mkdir -p /app/models

# Download Layer 1 - DeBERTa prompt injection
RUN python -c "from huggingface_hub import snapshot_download; \
    snapshot_download(repo_id='protectai/deberta-v3-base-prompt-injection-v2', \
    local_dir='/app/models/deberta', \
    local_dir_use_symlinks=False, \
    revision='main')"

# Download Layer 2 - NVIDIA Aegis safety
RUN python -c "from huggingface_hub import snapshot_download; \
    snapshot_download(repo_id='alexcm/MiniLM-L12-H384-uncased_NVIDIA-Aegis-AI-Safety', \
    local_dir='/app/models/minilm', \
    local_dir_use_symlinks=False, \
    revision='main')"

RUN chmod -R 777 /app/models

COPY app.py .

EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
