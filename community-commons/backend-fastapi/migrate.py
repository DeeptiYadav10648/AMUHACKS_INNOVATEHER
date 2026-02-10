"""
Simple migration runner for Community Commons MVP.

Usage:
    python migrate.py

This will execute SQL in `../database/init.sql` against the configured DATABASE_URL.
"""
import os
from pathlib import Path
from sqlalchemy import text
from app.db.session import engine


def run_sql_file(path: str):
    sql = Path(path).read_text()
    # Use a transaction context so commits are handled correctly across DB backends
    with engine.begin() as conn:
        for stmt in sql.split(';'):
            s = stmt.strip()
            if not s:
                continue
            conn.execute(text(s))


if __name__ == '__main__':
    here = Path(__file__).parent
    sql_file = here.parent.joinpath('..', 'database', 'init.sql').resolve()
    if not sql_file.exists():
        print('Migration SQL not found at', sql_file)
    else:
        print('Running migrations from', sql_file)
        run_sql_file(str(sql_file))
        print('Migrations applied (check DB).')
