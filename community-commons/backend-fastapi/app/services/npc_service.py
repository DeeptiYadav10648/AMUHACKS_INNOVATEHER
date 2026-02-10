from sqlalchemy.orm import Session
from ..models import models


def create_npc(db: Session, name: str, role: str):
    npc = models.NPC(name=name, role=role)
    db.add(npc)
    db.commit()
    db.refresh(npc)
    return npc


def set_relationship(db: Session, player_id: int, npc_id: int, delta: int, note: str = None):
    rel = db.query(models.NPCRelationship).filter(models.NPCRelationship.player_id == player_id, models.NPCRelationship.npc_id == npc_id).first()
    if not rel:
        rel = models.NPCRelationship(player_id=player_id, npc_id=npc_id, relationship_score=0)
        db.add(rel)
    rel.relationship_score = (rel.relationship_score or 0) + delta
    if note:
        rel.note = note
    db.commit()
    db.refresh(rel)
    return rel


def get_relationships(db: Session, player_id: int):
    rows = db.query(models.NPCRelationship).filter(models.NPCRelationship.player_id == player_id).all()
    result = []
    for r in rows:
        npc = db.query(models.NPC).filter(models.NPC.id == r.npc_id).first()
        result.append({
            'npc': {'id': npc.id, 'name': npc.name, 'role': npc.role} if npc else None,
            'relationship_score': r.relationship_score,
            'note': r.note,
        })
    return result
