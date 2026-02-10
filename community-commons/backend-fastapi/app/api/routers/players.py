from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from app.db.session import get_db
from app import models
from app.schemas import schemas
from app.services.players_service import create_player_profile, get_player
from app.services.badges_service import list_badges
import os

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


@router.post("/{player_id}/avatar")
def upload_avatar(player_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    player = get_player(db, player_id)
    if not player:
        raise HTTPException(status_code=404, detail="Player not found")
    # save uploaded avatar to uploads/ under backend-fastapi
    uploads_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), 'uploads')
    uploads_dir = os.path.normpath(uploads_dir)
    os.makedirs(uploads_dir, exist_ok=True)
    filename = f"player_{player_id}_avatar_{file.filename}"
    save_path = os.path.join(uploads_dir, filename)
    with open(save_path, 'wb') as f:
        f.write(file.file.read())
    # store path in player
    player.avatar = save_path
    db.add(player)
    db.commit()
    return {"player_id": player.id, "avatar": save_path}


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
