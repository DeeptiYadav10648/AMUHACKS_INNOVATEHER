from fastapi import FastAPI
from .api.routers import players, scenarios
from .db.session import engine
from .db import base as base_model

app = FastAPI(title='Community Commons API')

app.include_router(players.router, prefix="/api/players", tags=["players"])
app.include_router(scenarios.router, prefix="/api/scenarios", tags=["scenarios"])


@app.on_event("startup")
def on_startup():
    # create local tables for MVP
    base_model.Base.metadata.create_all(bind=engine)


@app.get("/")
def read_root():
    return {"msg": "Community Commons API running"}
