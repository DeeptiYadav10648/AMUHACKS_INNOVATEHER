from sqlalchemy.orm import Session
from ..models import models


def get_environment_state(db: Session, scenario_id: int):
    state = db.query(models.EnvironmentState).filter(models.EnvironmentState.scenario_id == scenario_id).first()
    if not state:
        state = models.EnvironmentState(scenario_id=scenario_id, state={})
        db.add(state)
        db.commit()
        db.refresh(state)
    return state


def update_environment_state(db: Session, scenario_id: int, new_state: dict):
    state = db.query(models.EnvironmentState).filter(models.EnvironmentState.scenario_id == scenario_id).first()
    if not state:
        state = models.EnvironmentState(scenario_id=scenario_id, state=new_state)
        db.add(state)
    else:
        state.state = new_state
    db.commit()
    db.refresh(state)
    return state
