# CityTrack: Civic Sense Simulator

A full-stack simulation game that tests your civic responsibility through interactive urban scenarios. Navigate through 5 different civic issues and make responsible choices to improve your Civic Sense Score!

## 🎮 Game Overview

**Concept:**  
You're exploring a city and encounter various civic problems. How you respond determines your level of civic consciousness.

**Features:**
- 🏙️ 5 Unique Urban Scenarios
- 🎯 Multiple Choice Decisions
- 📊 Dynamic Scoring System
- 🎨 Modern Clean UI with Smooth Animations
- 📱 Fully Responsive Design
- ⚡ Real-time Score Updates

## 📋 Game Scenarios

1. **Garbage Overflowing from Bin** - Overflowing trash creating unhygienic environment
2. **Broken Streetlight** - Non-functional streetlight creating safety concerns
3. **Pothole in Road** - Road hazard causing danger to vehicles and pedestrians
4. **Water Leakage from Pipeline** - Wasted drinking water from damaged pipeline
5. **Illegal Wall Poster / Vandalism** - Defacement of public property

## 🎮 Scoring System

For each scenario, you choose from 3 options:

- **Option A: Take Direct Responsible Action** → +20 points
- **Option B: Inform Authorities** → +10 points
- **Option C: Ignore Problem** → -10 points

**Maximum Possible Score:** 100 (5 scenes × 20 points)

### Result Categories

| Score | Rating | Message |
|-------|--------|---------|
| ≥ 80 | **Responsible Citizen** | Excellent civic contribution! |
| 50-79 | **Aware Citizen** | Good awareness, room for improvement |
| < 50 | **Needs Improvement** | Focus on civic responsibility |

## 🛠️ Tech Stack

**Frontend:**
- HTML5
- CSS3 (with Animations & Gradients)
- Vanilla JavaScript (No frameworks)

**Backend:**
- FastAPI (Python)
- Uvicorn (ASGI Server)

**Architecture:**
- Frontend communicates with Backend via REST API
- CORS enabled for cross-origin requests
- In-memory state management (no database)

## 📦 Project Structure

```
amu_project/
│
├── backend/
│   └── main.py                 # FastAPI server
│
├── frontend/
│   ├── index.html              # Game UI
│   ├── style.css               # Styling & Animations
│   └── script.js               # Game Logic
│
└── requirements.txt            # Python dependencies
```

## 🚀 Setup & Installation

### Prerequisites

- Python 3.8+
- pip (Python Package Manager)
- Modern Web Browser (Chrome, Firefox, Edge, Safari)

### Backend Setup

1. **Navigate to project directory:**
   ```bash
   cd c:\Users\Acer\OneDrive\Desktop\projects\amu_project
   ```

2. **Install Python Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run FastAPI Server:**
   ```bash
   python backend/main.py
   ```

   The server will start at `http://localhost:8000`

   You should see:
   ```
   Uvicorn running on http://0.0.0.0:8000
   ```

### Frontend Setup

1. **Open in Browser:**
   - Option A: Simply open `frontend/index.html` directly in your browser
   - Option B: Use a simple HTTP server (recommended for better experience)

   **Using Python's built-in HTTP Server:**
   ```bash
   cd frontend
   python -m http.server 5500
   ```
   Then visit: `http://localhost:5500`

2. **Ensure Backend is Running:**
   - Keep the FastAPI server running in a separate terminal
   - Frontend will communicate with `http://localhost:8000`

## 🎮 How to Play

1. **Start Game** - Click "START GAME" button on the welcome screen
2. **Read Scenario** - Understand the civic issue presented
3. **Make Decision** - Choose from 3 options (A, B, or C)
4. **Track Progress** - Watch your score and scene progress update
5. **Complete All 5 Scenes** - Navigate through all scenarios
6. **View Results** - See your Civic Sense Rating and Score Breakdown
7. **Play Again** - Restart the game or return to home screen

## 📊 API Endpoints

### Backend API Reference

All endpoints return JSON responses.

**Base URL:** `http://localhost:8000`

### 1. Get Scene Data
```http
GET /scene/{id}
```
**Parameters:**
- `id` (1-5): Scene ID

**Response:**
```json
{
  "scene": {
    "id": 1,
    "title": "Garbage Overflowing from Bin",
    "description": "You walk past a public area...",
    "background_emoji": "🗑️",
    "options": {
      "A": "Collect trash and dispose properly",
      "B": "Call municipal waste management authority",
      "C": "Ignore and walk away"
    }
  },
  "current_score": 0,
  "scene_number": 1,
  "total_scenes": 5
}
```

### 2. Submit Decision
```http
POST /submit-decision
Content-Type: application/json

{
  "scene_id": 1,
  "decision": "A"
}
```

**Response:**
```json
{
  "points_earned": 20,
  "total_score": 20,
  "next_scene": 2,
  "game_active": true,
  "completed_scenes": 1
}
```

### 3. Get Final Result
```http
GET /final-result
```

**Response:**
```json
{
  "score": 85,
  "rating": "Responsible Citizen",
  "message": "Excellent! You actively contributed...",
  "decisions": [
    {
      "scene_id": 1,
      "decision": "A",
      "points": 20
    },
    ...
  ]
}
```

### 4. Reset Game
```http
POST /reset-game
```

**Response:**
```json
{
  "message": "Game reset successfully"
}
```

## 🎨 UI Features

### Design Highlights
- **Color Palette:** Blue/Green urban theme
- **Responsive Layout:** Works on desktop, tablet, mobile
- **Smooth Animations:** Floating scores, wobbling emojis, smooth transitions
- **Modern Components:** Gradient buttons, progress bars, animated cards

### Screens
1. **Loading Screen** - Animated splash screen
2. **Start Screen** - Welcome with game features
3. **Game Screen** - Scene display with decision buttons
4. **Result Screen** - Final score and breakdown

## 🔧 Customization

### Modify Scoring
Edit in `backend/main.py`:
```python
DECISION_SCORES = {
    "A": 20,   # Change responsible action points
    "B": 10,   # Change inform authorities points
    "C": -10   # Change ignore points
}
```

### Add New Scenes
Add to `SCENES` dictionary in `backend/main.py`:
```python
SCENES = {
    6: {
        "id": 6,
        "title": "Your New Scenario",
        "description": "Detailed description...",
        "background_emoji": "🎯",
        "image_class": "scene-custom",
        "options": {
            "A": "Option A text",
            "B": "Option B text",
            "C": "Option C text"
        }
    }
    # Then update SCENES_PER_GAME in frontend/script.js
}
```

### Customize Colors
Edit in `frontend/style.css`:
```css
:root {
    --primary-color: #2d5f7d;        /* Change primary blue */
    --secondary-color: #3a8968;      /* Change green accent */
    --accent-color: #f39c12;         /* Change orange accent */
}
```

## 🐛 Troubleshooting

### Issue: "Cannot reach backend" error
**Solution:**
- Ensure FastAPI server is running: `python backend/main.py`
- Check server is on `http://localhost:8000`
- Verify no firewall blocking port 8000

### Issue: CORS errors in browser console
**Solution:**
- Backend CORS is already configured for all origins
- Make sure frontend is accessing correct API URL: `http://localhost:8000`

### Issue: Frontend loads but no scenes display
**Solution:**
- Open browser console (F12) for errors
- Check Network tab to see API responses
- Ensure backend server is running and accessible

### Issue: Styles not loading (in file:// mode)
**Solution:**
- Use HTTP server instead: `python -m http.server 5500`
- Open via `http://localhost:5500` instead of `file://`

## 📱 Responsive Features

- **Desktop (1024px+):** Full featured UI with all animations
- **Tablet (768px):** Optimized touch interface
- **Mobile (<480px):** Single column layout, touch-friendly buttons

## 🎯 Future Enhancements

- Leaderboard with score tracking
- Different difficulty modes
- More scenarios (10+ scenes)
- Multiplayer mode
- User accounts and progress saving
- Different city settings (urban, rural, industrial)
- Achievement badges and rewards

## 📄 License

This project is open-source and available for educational purposes.

## 👨‍💻 Development Notes

- **No Database:** All data stored in-memory (resets on server restart)
- **No Authentication:** Single-player, public access
- **Pure JavaScript:** No dependencies (Vanilla JS)
- **FastAPI:** Lightweight, modern Python web framework

## 📞 Support

For issues or questions:
1. Check the Troubleshooting section
2. Review browser console for error messages
3. Verify backend server is running
4. Check that ports 8000 (backend) and 5500 (frontend) are available

---

**Enjoy the game and improve your civic sense!** 🏙️✨
