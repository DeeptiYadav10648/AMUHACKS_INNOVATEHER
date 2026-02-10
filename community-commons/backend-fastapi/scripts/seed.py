"""
Seed initial scenarios and choices into the database.

Usage:
    python -m backend_fastapi.scripts.seed
or:
    python scripts/seed.py

This script uses the service layer `seed_scenarios` to create initial scenarios.
"""
from app.db.session import SessionLocal
from app.services.scenarios_service import seed_scenarios


def main():
    db = SessionLocal()
    try:
        seed_scenarios(db)
        print('Seeded scenarios.')
    finally:
        db.close()


if __name__ == '__main__':
    main()
