from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ...db.session import get_db
from ... import models
from ...schemas import schemas
from ...services.players_service import create_player_profile, get_player
from ...services.badges_service import list_badges

router = APIRouter()


@router.post("/", response_model=schemas.PlayerProfileRead)
def create_profile(profile: schemas.PlayerProfileCreate, db: Session = Depends(get_db)):
    return create_player_profile(db, profile)


@router.get("/{player_id}", response_model=schemas.PlayerProfileRead)
def read_profile(player_id: int, db: Session = Depends(get_db)):
    player = get_player(db, player_id)
    if not player:
        raise HTTPException(status_code=404, detail="Player not found")
    return player


@router.get("/{player_id}/progress")
def get_progress(player_id: int, db: Session = Depends(get_db)):
    player = get_player(db, player_id)
    if not player:
        raise HTTPException(status_code=404, detail="Player not found")

    # current civic score (take first row)
    score = db.query(models.CivicScore).filter(models.CivicScore.player_id == player.id).first()
    civic = score.to_dict() if score else {"community_harmony":0, "personal_integrity":0, "social_capital":0}

    # badges
    badges = list_badges(db, player.id)

    # unlocked scenarios by total score
    total = civic['community_harmony'] + civic['personal_integrity'] + civic['social_capital']
    unlocked = db.query(models.Scenario).filter(models.Scenario.unlock_score <= total).all()
    unlocked_list = [ { 'id': s.id, 'title': s.title, 'environment': s.environment } for s in unlocked ]

    return {
        "player_id": player.id,
        "civic_scores": civic,
        "badges": badges,
        "unlocked_scenarios": unlocked_list,
    }
