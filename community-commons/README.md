# Community Commons — Civic Responsibility Awareness Game (MVP)

This repository contains an MVP for "Community Commons", a scenario-based civic responsibility simulation game.

Structure:

- `/godot-game` — Godot Engine 2D game scenes and scripts (GDScript).
- `/backend-fastapi` — FastAPI backend, SQLAlchemy models, API routers.
- `/database` — SQL migration / init SQL.
- `/docs` — Documentation and notes.

Follow the step-by-step files in the root of each folder to run the game and the API.

Goals (MVP):
- Create character and save profile
- Play scenarios (Public Transit, Residential Area, Public Park)
- Make choices that update civic metrics
- See score changes on HUD and unlock next scenario
