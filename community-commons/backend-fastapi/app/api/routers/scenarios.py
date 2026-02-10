
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ...db.session import get_db
from ...schemas import schemas
from ...services.scenarios_service import list_scenarios, apply_decision

router = APIRouter()


@router.get("/")
def get_scenarios(db: Session = Depends(get_db)):
    scenarios = list_scenarios(db)
    result = []
    for s in scenarios:
        result.append({
            'id': s.id,
            'title': s.title,
            'environment': s.environment,
            'description': s.description,
            'choices': [c.to_dict() for c in s.choices]
        })
    return result


@router.post("/{scenario_id}/decide", response_model=schemas.DecisionResult)
def decide(scenario_id: int, payload: schemas.DecisionCreate, db: Session = Depends(get_db)):
    return apply_decision(db, scenario_id, payload)
