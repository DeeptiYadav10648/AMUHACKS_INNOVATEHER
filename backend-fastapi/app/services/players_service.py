from sqlalchemy.orm import Session
from ..models import models


def create_player_profile(db: Session, profile_in):
    player = models.PlayerProfile(name=profile_in.name, background=profile_in.background, avatar=profile_in.avatar)
    db.add(player)
    db.commit()
    db.refresh(player)
    # initialize civic scores
    score = models.CivicScore(player_id=player.id, community_harmony=0, personal_integrity=0, social_capital=0)
    db.add(score)
    db.commit()
    db.refresh(score)
    return player


def get_player(db: Session, player_id: int):
    return db.query(models.PlayerProfile).filter(models.PlayerProfile.id == player_id).first()
