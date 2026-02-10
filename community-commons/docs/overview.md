# Community Commons — Overview

This document describes the high level design and how components interact.

- Godot front-end (2D) — calls backend REST APIs to create players, fetch scenarios, submit decisions.
- FastAPI backend — provides JSON APIs, manages SQLAlchemy models and persistence.
- Database — PostgreSQL for production; SQLite fallback in local dev.

Next steps: wire Godot `HTTPRequest` nodes to the endpoints in `backend-fastapi`.
