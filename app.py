from fastapi import FastAPI
from transformers import pipeline

app = FastAPI()

safety_model = pipeline(
    "text-classification",
    model="/app/models/minilm"
)

jailbreak_model = pipeline(
    "text-classification",
    model="/app/models/deberta"
)

@app.post("/predict")
def predict(data: dict):
    text = data["text"]

    safety = safety_model(text)
    jailbreak = jailbreak_model(text)

    return {
        "safety": safety,
        "jailbreak": jailbreak
    }
