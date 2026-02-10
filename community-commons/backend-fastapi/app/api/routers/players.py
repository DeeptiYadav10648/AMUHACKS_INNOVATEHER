from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ...db.session import get_db
from ... import models
from ...schemas import schemas
from ...services.players_service import create_player_profile, get_player

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


@router.get("/{player_id}/progress", response_model=schemas.PlayerProgress)
def get_progress(player_id: int, db: Session = Depends(get_db)):
    player = get_player(db, player_id)
    if not player:
        raise HTTPException(status_code=404, detail="Player not found")
    return {
        "player_id": player.id,
        "civic_scores": [s.to_dict() for s in player.civic_scores]
    }
