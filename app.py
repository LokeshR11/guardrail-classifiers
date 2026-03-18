from fastapi import FastAPI, Request
from transformers import pipeline

app = FastAPI()

# — Load all 3 models at startup ————————————————————————————————
safety_model = pipeline(
    "text-classification",
    model="/app/models/minilm",
    top_k=None,          # return all labels with scores
)

jailbreak_model = pipeline(
    "text-classification",
    model="/app/models/deberta",
    top_k=None,
)

sql_model = pipeline(
    "text-classification",
    model="/app/models/mobilebert",
    top_k=None,
)


# — Core predict logic ———————————————————————————————————————————
def run_predict(data: dict) -> dict:
    text = data["text"]
    safety    = safety_model(text)
    jailbreak = jailbreak_model(text)
    sql       = sql_model(text)
    return {
        "safety":    safety,
        "jailbreak": jailbreak,
        "sql":       sql,
    }



@app.post("/predict")
async def predict_v0(request: Request):
    data = await request.json()
    return run_predict(data)

@app.post("/v1/predict")
async def predict_v1(request: Request):
    data = await request.json()
    return run_predict(data)

@app.post("/v2/predict")
async def predict_v2(request: Request):
    data = await request.json()
    return run_predict(data)


# — Health check —————————————————————————————————————————————————

@app.get("/")
def root():
    return {"status": "ok"}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/v1/health")
def health_v1():
    return {"status": "ok"}

@app.get("/v2/health")
def health_v2():
    return {"status": "ok"}
