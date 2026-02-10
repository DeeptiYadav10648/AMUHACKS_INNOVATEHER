# Backend FastAPI

Start the API locally (development):

1. Create a virtual environment and install requirements:

```bash
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

2. Run with uvicorn:

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

3. Apply migrations (runs the SQL in `../database/init.sql`):

```bash
python migrate.py
```

4. Seed scenarios (optional if you rely on API seed):

```bash
python scripts/seed.py
```

