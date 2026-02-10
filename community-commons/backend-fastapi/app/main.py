from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from .api.routers import players, scenarios, npcs, environment
from .db.session import engine
from .db import base as base_model
import os

app = FastAPI(title='Community Commons API')

app.include_router(players.router, prefix="/api/players", tags=["players"])
app.include_router(scenarios.router, prefix="/api/scenarios", tags=["scenarios"])
app.include_router(npcs.router, prefix="/api/npcs", tags=["npcs"])
app.include_router(environment.router, prefix="/api/environment", tags=["environment"])

# serve uploads (avatars) directory if present
uploads_path = os.path.join(os.path.dirname(__file__), '..', 'uploads')
uploads_path = os.path.normpath(uploads_path)
if os.path.isdir(uploads_path):
    app.mount("/uploads", StaticFiles(directory=uploads_path), name="uploads")


@app.on_event("startup")
def on_startup():
    # create local tables for MVP
    base_model.Base.metadata.create_all(bind=engine)


@app.get("/")
def read_root():
    return {"msg": "Community Commons API running"}
