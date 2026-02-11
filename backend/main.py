from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional

app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Game state storage (in-memory)
game_state = {
    "score": 0,
    "current_scene": 1,
    "completed_scenes": 0,
    "game_active": True,
    "decisions": []
}

# Scene data
SCENES = {
    1: {
        "id": 1,
        "title": "Garbage Overflowing from Bin",
        "description": "You walk past a public area and notice the garbage bin is overflowing with trash. Litter is scattered around on the ground, creating an unhygienic environment.",
        "background_emoji": "🗑️",
        "image_class": "scene-garbage",
        "options": {
            "A": "Collect trash and dispose properly",
            "B": "Call municipal waste management authority",
            "C": "Ignore and walk away"
        }
    },
    2: {
        "id": 2,
        "title": "Broken Streetlight",
        "description": "A streetlight in a busy neighborhood is broken and hasn't been working for weeks. Pedestrians struggle to see in the dark, creating safety concerns.",
        "background_emoji": "💡",
        "image_class": "scene-light",
        "options": {
            "A": "Report to local maintenance crew and help fix it",
            "B": "Notify the municipal corporation's maintenance department",
            "C": "Ignore - not your responsibility"
        }
    },
    3: {
        "id": 3,
        "title": "Pothole in Road",
        "description": "A deep pothole has formed in the middle of the road, making it hazardous for vehicles and pedestrians. Rain water is pooling inside it.",
        "background_emoji": "🕳️",
        "image_class": "scene-pothole",
        "options": {
            "A": "Mark the pothole and alert nearby communities",
            "B": "Report to public works department with location details",
            "C": "Leave it as is - too risky to handle alone"
        }
    },
    4: {
        "id": 4,
        "title": "Water Leakage from Pipeline",
        "description": "Water is continuously leaking from a damaged pipeline, wasting freshwater and creating muddy patches. People are losing valuable drinking water.",
        "background_emoji": "💧",
        "image_class": "scene-water",
        "options": {
            "A": "Temporarily stop the leak and alert residents",
            "B": "Call water authority to repair the pipeline",
            "C": "Ignore - someone else will notice"
        }
    },
    5: {
        "id": 5,
        "title": "Illegal Wall Poster / Vandalism",
        "description": "Illegal advertisements and vandalism cover a historic public wall. The defacement damages the wall and spoils the area's aesthetics.",
        "background_emoji": "🎨",
        "image_class": "scene-vandalism",
        "options": {
            "A": "Organize community cleanup and removal of posters",
            "B": "Report to municipal corporation's beautification department",
            "C": "Ignore - decorates the boring wall"
        }
    }
}

# Decision scoring
DECISION_SCORES = {
    "A": 20,   # Responsible action
    "B": 10,   # Inform authorities
    "C": -10   # Ignore
}

class DecisionRequest(BaseModel):
    scene_id: int
    decision: str  # A, B, or C

@app.get("/")
def read_root():
    return {"message": "CityTrack: Civic Sense Simulator - Backend Running"}

@app.get("/scene/{scene_id}")
def get_scene(scene_id: int):
    if scene_id not in SCENES:
        return {"error": "Scene not found"}
    
    scene = SCENES[scene_id]
    return {
        "scene": scene,
        "current_score": game_state["score"],
        "scene_number": scene_id,
        "total_scenes": 5
    }

@app.post("/submit-decision")
def submit_decision(decision_request: DecisionRequest):
    scene_id = decision_request.scene_id
    decision = decision_request.decision
    
    if scene_id not in SCENES:
        return {"error": "Invalid scene"}
    
    if decision not in DECISION_SCORES:
        return {"error": "Invalid decision"}
    
    # Calculate points
    points = DECISION_SCORES[decision]
    game_state["score"] += points
    game_state["decisions"].append({
        "scene_id": scene_id,
        "decision": decision,
        "points": points
    })
    
    # Move to next scene
    game_state["completed_scenes"] += 1
    
    if game_state["completed_scenes"] >= 5:
        game_state["game_active"] = False
    else:
        game_state["current_scene"] += 1
    
    return {
        "points_earned": points,
        "total_score": game_state["score"],
        "next_scene": game_state["current_scene"],
        "game_active": game_state["game_active"],
        "completed_scenes": game_state["completed_scenes"]
    }

@app.get("/final-result")
def get_final_result():
    final_score = game_state["score"]
    
    if final_score >= 80:
        rating = "Responsible Citizen"
        message = "Excellent! You actively contributed to improving your community!"
    elif final_score >= 50:
        rating = "Aware Citizen"
        message = "Good! You have civic consciousness. Keep improving!"
    else:
        rating = "Needs Improvement"
        message = "You need to be more responsible towards your community's civic issues."
    
    return {
        "score": final_score,
        "rating": rating,
        "message": message,
        "decisions": game_state["decisions"]
    }

@app.post("/reset-game")
def reset_game():
    global game_state
    game_state = {
        "score": 0,
        "current_scene": 1,
        "completed_scenes": 0,
        "game_active": True,
        "decisions": []
    }
    return {"message": "Game reset successfully"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
