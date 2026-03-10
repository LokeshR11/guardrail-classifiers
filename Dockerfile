FROM python:3.10

WORKDIR /app


COPY requirements.txt .

# install dependencies
RUN pip install --no-cache-dir -r requirements.txt


RUN mkdir -p /app/models


RUN huggingface-cli download microsoft/MiniLM-L12-H384-uncased \
    --local-dir /app/models/minilm

RUN huggingface-cli download microsoft/deberta-v3-base \
    --local-dir /app/models/deberta


COPY app.py .

# run server
CMD ["uvicorn","app:app","--host","0.0.0.0","--port","8000"]
