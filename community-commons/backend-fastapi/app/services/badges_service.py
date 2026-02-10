from sqlalchemy.orm import Session
from ..models import models

# Simple badge rules: map badge name to total score threshold
BADGE_RULES = [
    ("Community Helper", 5, "Recognized for small acts of civic kindness."),
    ("Civic Builder", 15, "Consistent contributor to community wellbeing."),
    ("Civic Leader", 30, "Outstanding leadership in civic responsibility."),
]


def evaluate_and_award_badges(db: Session, player_id: int, score_row: models.CivicScore):
    """Evaluate badge rules against player's current composite score and award any new badges.

    Returns list of awarded badge dicts.
    """
    total = (score_row.community_harmony or 0) + (score_row.personal_integrity or 0) + (score_row.social_capital or 0)
    existing = db.query(models.Badge).filter(models.Badge.player_id == player_id).all()
    existing_names = {b.name for b in existing}
    awarded = []
    for name, threshold, description in BADGE_RULES:
        if total >= threshold and name not in existing_names:
            b = models.Badge(player_id=player_id, name=name, description=description)
            db.add(b)
            awarded.append({"name": name, "description": description, "threshold": threshold})
    if awarded:
        db.commit()
    return awarded


def list_badges(db: Session, player_id: int):
    badges = db.query(models.Badge).filter(models.Badge.player_id == player_id).all()
    return [ {"id": b.id, "name": b.name, "description": b.description} for b in badges ]
