from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.services.env_service import get_environment_state, update_environment_state

router = APIRouter()


@router.get("/{scenario_id}")
def get_env(scenario_id: int, db: Session = Depends(get_db)):
    state = get_environment_state(db, scenario_id)
    return {"scenario_id": state.scenario_id, "state": state.state}


@router.post("/{scenario_id}")
def post_env(scenario_id: int, payload: dict, db: Session = Depends(get_db)):
    state = update_environment_state(db, scenario_id, payload)
    return {"scenario_id": state.scenario_id, "state": state.state}
