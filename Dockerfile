FROM python:3.10-slim
WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Step 1 — install all requirements first (lets transformers pick any torch)
RUN pip install --no-cache-dir -r requirements.txt


RUN pip install --no-cache-dir --upgrade --force-reinstall \
    "torch>=2.6.0" --index-url https://download.pytorch.org/whl/cpu

ENV HF_HOME=/tmp
ENV TRANSFORMERS_CACHE=/tmp

RUN mkdir -p /app/models

# Download Layer 1 — DeBERTa prompt injection
RUN python -c "from huggingface_hub import snapshot_download; \
    snapshot_download(repo_id='protectai/deberta-v3-base-prompt-injection-v2', \
    local_dir='/app/models/deberta', \
    local_dir_use_symlinks=False, \
    revision='main')"

# Download Layer 2 — NVIDIA Aegis safety
RUN python -c "from huggingface_hub import snapshot_download; \
    snapshot_download(repo_id='alexc09/MiniLM-L12-H384-uncased_Nvidia-Aegis-AI-Safety', \
    local_dir='/app/models/minilm', \
    local_dir_use_symlinks=False, \
    revision='main')"

# Download Layer 3 — MobileBERT SQL injection
RUN python -c "from huggingface_hub import snapshot_download; \
    snapshot_download(repo_id='cssupport/mobilebert-sql-injection-detect', \
    local_dir='/app/models/mobilebert', \
    local_dir_use_symlinks=False, \
    revision='main')"

RUN chmod -R 777 /app/models

COPY app.py .

EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
