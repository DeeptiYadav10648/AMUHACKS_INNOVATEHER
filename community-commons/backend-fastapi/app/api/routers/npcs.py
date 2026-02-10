from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.services.npc_service import create_npc, set_relationship, get_relationships

router = APIRouter()


@router.post("/")
def create_npc_endpoint(name: str, role: str, db: Session = Depends(get_db)):
    npc = create_npc(db, name, role)
    return {"id": npc.id, "name": npc.name, "role": npc.role}


@router.post("/relationship")
def set_relationship_endpoint(player_id: int, npc_id: int, delta: int = 0, note: str = None, db: Session = Depends(get_db)):
    rel = set_relationship(db, player_id, npc_id, delta, note)
    return {"id": rel.id, "player_id": rel.player_id, "npc_id": rel.npc_id, "relationship_score": rel.relationship_score}


@router.get("/player/{player_id}")
def list_relationships(player_id: int, db: Session = Depends(get_db)):
    return get_relationships(db, player_id)
