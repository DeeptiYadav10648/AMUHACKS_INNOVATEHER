from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app import models
from app.schemas import schemas
from app.services.scenarios_service import list_scenarios, get_scenario, apply_decision

router = APIRouter()


@router.get("/")
def get_scenarios(db: Session = Depends(get_db)):
    """Get all available scenarios"""
    scenarios = list_scenarios(db)
    return [
        {
            "id": s.id,
            "title": s.title,
            "environment": s.environment,
            "description": s.description,
            "choices": [c.to_dict() for c in s.choices],
        }
        for s in scenarios
    ]


@router.get("/{scenario_id}")
def get_scenario_detail(scenario_id: int, db: Session = Depends(get_db)):
    """Get a specific scenario by ID"""
    scenario = get_scenario(db, scenario_id)
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")
    return {
        "id": scenario.id,
        "title": scenario.title,
        "environment": scenario.environment,
        "description": scenario.description,
        "choices": [c.to_dict() for c in scenario.choices],
    }


@router.post("/{scenario_id}/decide")
def submit_decision(scenario_id: int, payload: dict, db: Session = Depends(get_db)):
    """Submit a decision for a scenario"""
    try:
        result = apply_decision(db, scenario_id, payload)
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/{player_id}/scores")
def get_scores(player_id: int, db: Session = Depends(get_db)):
    """Get current scores for a player"""
    score = db.query(models.CivicScore).filter(
        models.CivicScore.player_id == player_id
    ).first()
    if not score:
        raise HTTPException(status_code=404, detail="Player not found")
    return score.to_dict()
