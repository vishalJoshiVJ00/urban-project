from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Query(BaseModel):
    question: str

@app.post("/citybrain")
def city_brain(query: Query):
    return {
        "answer": f"CityBrain analyzed: '{query.question}'. Action: Deploy field team immediately.",
        "confidence": 0.95
    }