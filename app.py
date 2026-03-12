from fastapi import FastAPI
from transformers import pipeline

app = FastAPI()

# ── Load all 3 models at startup ──────────────────────────────────────────────

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


# ── Single predict endpoint ───────────────────────────────────────────────────

@app.post("/predict")
def predict(data: dict):
    text = data["text"]

    safety    = safety_model(text)
    jailbreak = jailbreak_model(text)
    sql       = sql_model(text)

    return {
        "safety":    safety,
        "jailbreak": jailbreak,
        "sql":       sql,
    }


# ── Health check ──────────────────────────────────────────────────────────────

@app.get("/health")
def health():
    return {"status": "ok"}
