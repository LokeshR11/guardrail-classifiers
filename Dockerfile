FROM python:3.10

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

RUN mkdir -p /app/models

# Download models during build
RUN huggingface-cli download microsoft/MiniLM-L12-H384-uncased \
    --local-dir /app/models/minilm

RUN huggingface-cli download microsoft/deberta-v3-base \
    --local-dir /app/models/deberta

COPY app.py .

CMD ["uvicorn","app:app","--host","0.0.0.0","--port","8000"]
