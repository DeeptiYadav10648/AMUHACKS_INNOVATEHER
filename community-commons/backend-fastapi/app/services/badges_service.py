from sqlalchemy.orm import Session


def list_badges(db: Session, player_id: int):
    # Minimal placeholder: return any badge rows if present
    try:
        rows = db.execute("SELECT id, name, description FROM badges WHERE player_id = :pid", {"pid": player_id}).fetchall()
        return [ {"id": r[0], "name": r[1], "description": r[2]} for r in rows ]
    except Exception:
        return []
