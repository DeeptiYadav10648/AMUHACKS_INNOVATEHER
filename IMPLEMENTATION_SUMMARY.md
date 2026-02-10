# MVP: Playable Civic Scenario Loop - Implementation Summary

## Overview
This implementation enables the **first playable game loop** where players can:
1. Create a character profile
2. Play through civic scenarios
3. Make choices that affect their scores
4. See updated scores and NPC reactions

---

## STEP 1 - Backend Implementation ✅

### Completed:
- **Models** (already existed):
  - `PlayerProfile` - name, background, avatar
  - `Scenario` - title, description, environment
  - `Choice` - scenario_id, text, effect (JSON with score impacts)
  - `DecisionHistory` - tracks all player decisions
  - `CivicScore` - community_harmony, personal_integrity, social_capital

- **API Endpoints**:
  - `POST /api/players/` - Create player profile (returns player ID)
  - `GET /api/scenarios/` - List all scenarios with choices
  - `GET /api/scenarios/{id}` - Get specific scenario details
  - `POST /api/scenarios/{id}/decide` - Submit a decision and get updated scores
  - `GET /api/scenarios/{player_id}/scores` - Get current player scores (optional)

- **Service Layer**:
  - `scenarios_service.py` with:
    - `list_scenarios()` - auto-seeds if DB is empty
    - `get_scenario()` - fetch by ID
    - `seed_scenarios()` - populates sample "Late-Night Neighbor" scenario with 4 choices
    - `apply_decision()` - updates scores, records decision, returns feedback

---

## STEP 2 - Database ✅

### Database Schema (already defined in `database/init.sql`):
- `player_profiles` table
- `civic_scores` table
- `scenarios` table
- `choices` table (with JSONB `effect` column)
- `decisions_history` table

### Sample Scenario Data:
Seeded by `scenarios_service.seed_scenarios()`:
- **Title**: "Late-Night Neighbor"
- **Environment**: "Residential Area"
- **Description**: Dealing with neighbor playing loud music at midnight
- **Choices** (with score impacts):
  1. Call police → {harmony: -2, integrity: +1, social: -3}
  2. Knock politely → {harmony: +2, integrity: +2, social: +1}
  3. Leave note → {harmony: 0, integrity: 0, social: 0}
  4. Invite to future event → {harmony: +3, integrity: +1, social: +3}

---

## STEP 3 - Godot Integration ✅

### Files Created/Modified:

#### 1. **scripts/GameState.gd** (autoload singleton)
- Stores `player_id` across scenes
- Stores `civic_scores` dictionary
- Backend URL constant: `http://127.0.0.1:8000/api`
- `update_scores()` method to refresh scores after decisions

#### 2. **scripts/CharacterCreation.gd**
- References: `$NameLineEdit`, `$BackgroundOption`, `$CreateButton`, `$HTTPRequest`
- Flow:
  1. User enters name and selects background
  2. POST request to `/api/players/` with player data
  3. Stores returned `player_id` in GameState autoload
  4. Changes scene to `res://scenes/Scenario.tscn`

#### 3. **scripts/Scenario.gd**
- References: `$Description`, `$Choice1-4`, `$ScoreHUD`, `$NPCDialogue`, `$HTTPRequest`
- Flow:
  1. On ready: fetch scenarios from `/api/scenarios/`
  2. Display current scenario description and 4 choice buttons
  3. On choice click: POST decision to `/api/scenarios/{id}/decide`
  4. Update GameState scores with response
  5. Show NPC reaction message
  6. Advance to next scenario after 2-second delay

#### 4. **scripts/Main.gd**
- Simple entry point; instances CharacterCreation scene

---

## STEP 4 - UI Connection ✅

### Scene Definitions:

#### **CharacterCreation.tscn**
Nodes:
- `Title` (Label)
- `NameLabel` + `NameLineEdit`
- `BackgroundLabel` + `BackgroundOption` (dropdown with Student/Worker/Retiree/Educator)
- `CreateButton`
- `HTTPRequest` (for API calls)

#### **Scenario.tscn**
Nodes:
- `Title` (Label)
- `Description` (Label - scenario text)
- `Choice1-4` (Buttons - player choices)
- `ScoreHUD` (Label - current scores)
- `NPCDialogue` (Label - NPC reaction)
- `HTTPRequest` (for API calls)

#### **Main.tscn**
- Simple root scene that hosts CharacterCreation initially

---

## Global Configuration

### **project.godot** - Updated with:
```
[autoload]
GameState="*res://scripts/GameState.gd"

[application]
config/name="Community Commons"
run/main_scene="res://scenes/Main.tscn"

[display]
window/size/width=1024
window/size/height=600
```

---

## Gameplay Flow (MVP Loop)

```
Main Menu
    ↓
Character Creation
    ├─ Enter name
    ├─ Select background
    └─ Submit → Create player via API
         ↓
    Store player_id in GameState
         ↓
Scenario Scene (Loop)
    ├─ Load scenario from API
    ├─ Display description + 4 choices
    ├─ Player selects choice
    └─ Submit decision → Update scores
         ↓
    Update HUD with new scores
    Show NPC reaction (2 sec)
         ↓
    Load next scenario or end
```

---

## Performance & Testing

### Prerequisites:
1. FastAPI backend running on `http://127.0.0.1:8000`
2. Database initialized with `database/init.sql`
3. Godot project with all scenes and scripts in place
4. GameState autoload registered in project.godot

### Expected Behavior:
1. ✅ Player creates profile → API POST succeeds, returns ID
2. ✅ Scenario loads → API GET returns scenario with choices
3. ✅ Decision submitted → API POST updates scores in DB
4. ✅ Scores display → Godot HUD shows updated values
5. ✅ Loop continues → Next scenario loads or ends gracefully

---

## API Response Examples

### POST /api/players/ (Create Player)
```json
{
  "id": 1,
  "name": "Alice",
  "background": "Student",
  "avatar": null
}
```

### GET /api/scenarios/ (List Scenarios)
```json
[
  {
    "id": 1,
    "title": "Late-Night Neighbor",
    "environment": "Residential Area",
    "description": "...",
    "choices": [
      { "id": 1, "text": "Call police", "effect": {...} },
      { "id": 2, "text": "Knock politely", "effect": {...} },
      ...
    ]
  }
]
```

### POST /api/scenarios/{id}/decide (Submit Decision)
```json
{
  "decision_id": 1,
  "choice_text": "Call police",
  "updated_scores": {
    "community_harmony": 5,
    "personal_integrity": 6,
    "social_capital": 2
  },
  "message": "Police arrived and left a noise citation."
}
```

---

## Summary of Files Modified/Created

| File | Type | Changes |
|------|------|---------|
| `app/api/routers/scenarios.py` | New | Scenarios endpoints |
| `app/services/scenarios_service.py` | Updated | Added `get_scenario()` |
| `godot-game/scripts/GameState.gd` | Existing | Game state singleton |
| `godot-game/scripts/CharacterCreation.gd` | Updated | Profile creation flow |
| `godot-game/scripts/Scenario.gd` | Updated | Scenario and decision logic |
| `godot-game/scripts/Main.gd` | Existing | Entry point |
| `godot-game/scenes/CharacterCreation.tscn` | Updated | UI nodes with layout |
| `godot-game/scenes/Scenario.tscn` | Updated | Scenario UI with 4 choices |
| `godot-game/scenes/Main.tscn` | Existing | Root scene |
| `godot-game/project.godot` | Updated | Autoload + window config |
| `database/init.sql` | Existing | No changes needed |
| `app/main.py` | Existing | Already has router imports |

---

## Next Steps (Post-MVP)

- [ ] Add more scenarios (currently 1 seeded)
- [ ] Implement NPC relationship tracking per decision
- [ ] Add badge unlocks based on score thresholds
- [ ] Polish Godot UI (fonts, colors, animations)
- [ ] Add main menu scene
- [ ] Implement save/load game state
- [ ] Add sound effects and music
- [ ] Prepare for Postgres/production deployment
- [ ] Create export builds for Web/Mobile/Desktop

---

## Running the MVP

### Backend:
```bash
cd community-commons/backend-fastapi
python -m uvicorn app.main:app --port 8000
```

### Godot:
1. Open Godot Editor
2. Load project from `godot-game/`
3. Run scene or press F5

### Expected First Run:
- Player creates profile
- Scenario loads
- Player makes choice
- Scores update
- Next scenario loads or completes

