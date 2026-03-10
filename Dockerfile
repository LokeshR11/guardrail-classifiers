FROM python:3.10

WORKDIR /app

# Copy requirements first (better Docker caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Set HuggingFace cache to temporary directory
ENV HF_HOME=/tmp
ENV TRANSFORMERS_CACHE=/tmp

# Create model directory
RUN mkdir -p /app/models

# Download MiniLM model
RUN python -c "from huggingface_hub import snapshot_download; \
snapshot_download(repo_id='microsoft/MiniLM-L12-H384-uncased', \
local_dir='/app/models/minilm', \
local_dir_use_symlinks=False, \
revision='main')"

# Download DeBERTa model
RUN python -c "from huggingface_hub import snapshot_download; \
snapshot_download(repo_id='microsoft/deberta-v3-base', \
local_dir='/app/models/deberta', \
local_dir_use_symlinks=False, \
revision='main')"


COPY app.py .

# Expose API port
EXPOSE 8000

# Start FastAPI server
CMD ["uvicorn","app:app","--host","0.0.0.0","--port","8000"]
