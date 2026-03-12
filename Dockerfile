FROM python:3.10-slim
WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Step 1 — upgrade pip 
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
RUN pip install --no-cache-dir "typing-extensions>=4.10.0"

COPY requirements.txt .

# Step 2 — install requirements (transformers, tiktoken etc.)
# using --no-deps for conflict-prone packages
RUN pip install --no-cache-dir -r requirements.txt

# Step 3 — install torch CPU with --no-deps to bypass resolver conflict
# then install torch's actual deps separately
RUN pip install --no-cache-dir --no-deps \
    "torch==2.6.0+cpu" \
    --index-url https://download.pytorch.org/whl/cpu

# Step 4 — install torch's required deps explicitly
RUN pip install --no-cache-dir \
    "typing-extensions>=4.10.0" \
    "filelock" \
    "sympy" \
    "networkx" \
    "jinja2" \
    "fsspec"

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
