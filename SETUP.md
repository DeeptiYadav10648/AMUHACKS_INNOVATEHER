# 🎮 CITYTRACK - SETUP & RUN GUIDE (Windows)

## Quick Start (Easiest Way)

### Option 1: Automated Start (Recommended for Windows)

1. **Open PowerShell** as Administrator
2. **Navigate to project:**
   ```powershell
   cd "c:\Users\Acer\OneDrive\Desktop\projects\amu_project"
   ```

3. **Run the auto-start script:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File start-game.ps1
   ```

   This will:
   - ✅ Check Python installation
   - ✅ Install all dependencies
   - ✅ Start backend server
   - ✅ Start frontend server
   - ✅ Open game in your browser
   - 🎮 Game opens automatically!

4. **When done:** Press Enter to close all servers

---

## Manual Setup (Step-by-Step)

### Step 1: Install Dependencies

```powershell
cd "c:\Users\Acer\OneDrive\Desktop\projects\amu_project"
pip install -r requirements.txt
```

**You should see:**
```
Successfully installed fastapi-0.110.0 uvicorn-0.27.0 pydantic-2.5.3 ...
```

---

### Step 2: Start Backend Server

**Open PowerShell Window #1:**

```powershell
cd "c:\Users\Acer\OneDrive\Desktop\projects\amu_project"
python backend/main.py
```

**You should see:**
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Started server process [12345]
INFO:     Waiting for application startup.
INFO:     Application startup complete
```

✅ **Backend is running!** Do NOT close this window.

---

### Step 3: Start Frontend Server

**Open PowerShell Window #2:**

```powershell
cd "c:\Users\Acer\OneDrive\Desktop\projects\amu_project\frontend"
python -m http.server 5500
```

**You should see:**
```
Serving HTTP on 0.0.0.0 port 5500 (http://0.0.0.0:5500/)
```

✅ **Frontend is running!** Do NOT close this window.

---

### Step 4: Play the Game!

**Open your web browser and visit:**
```
http://localhost:5500
```

The game should load immediately! 🏙️

---

## 🔍 Verify Everything is Working

### Check Backend

- Open: `http://localhost:8000/`
- You should see:
  ```json
  {"message": "CityTrack: Civic Sense Simulator - Backend Running"}
  ```

### Check API Documentation

- Open: `http://localhost:8000/docs`
- You should see the Swagger UI with all endpoints

### Check Frontend

- Open: `http://localhost:5500`
- You should see the CityTrack start screen

---

## ⚠️ Troubleshooting

### Problem: "Python not found"
**Solution:**
- Python isn't installed or not in PATH
- Install Python from: https://www.python.org/downloads/
- During installation, ✓ Check "Add Python to PATH"
- Restart PowerShell after installation

### Problem: "Port 8000 already in use"
**Solution:**
```powershell
# Find process using port 8000
netstat -ano | findstr :8000

# Kill the process (use PID from above)
taskkill /PID <PID> /F
```

### Problem: "Port 5500 already in use"
**Solution:**
Change frontend port:
```powershell
cd frontend
python -m http.server 6000  # Use 6000 instead of 5500
```
Then open: `http://localhost:6000`

### Problem: "The server is unreachable"
**Solution:**
- Make sure BOTH windows (backend and frontend) are running
- Check Windows Firewall isn't blocking Python
- Try opening browser in Incognito mode
- Clear browser cache (Ctrl+Shift+Del)

### Problem: "CORS error in browser console"
**Solution:**
- Backend already has CORS enabled
- Make sure you're using the correct API URL: `http://localhost:8000`
- Check Network tab in DevTools (F12) for exact error

### Problem: "Styles not loading (page looks ugly)"
**Solution:**
- Don't open `index.html` directly (file:// mode)
- Use the HTTP server: `python -m http.server 5500`
- Then visit: `http://localhost:5500`

---

## 🎮 Playing the Game

### Game Flow:
1. **Welcome Screen** → Click "START GAME"
2. **Scene Appears** → Read the civic issue
3. **Make a Choice** → Click Option A, B, or C
4. **Score Updates** → See points earned
5. **Next Scene** → Automatically loads next scenario
6. **Repeat** → Play all 5 scenes
7. **Results** → View final Civic Sense Rating

### Scoring:
- **Option A** (Take Direct Action) = +20 points
- **Option B** (Inform Authorities) = +10 points
- **Option C** (Ignore Problem) = -10 points

### Results:
- **Score ≥ 80** = Responsible Citizen ✅
- **Score 50-79** = Aware Citizen ⚠️
- **Score < 50** = Needs Improvement ❌

---

## 📝 Important Notes

⚠️ **Game restarts every time you refresh**
- All progress is reset unless you complete all 5 scenes and see results
- Backend stores data in memory only (no database)
- Restarting backend clears all game data

⚠️ **Keep both windows open**
- Window 1: Backend (http://localhost:8000)
- Window 2: Frontend (http://localhost:5500)
- Close Window 1 (Backend) = Game stops working
- You can minimize them, just don't close them

⚠️ **Use Modern Browser**
- Chrome, Firefox, Edge, or Safari recommended
- Not tested on IE11

---

## 🚀 Advanced Options

### Use Different Frontend Port:
```powershell
cd frontend
python -m http.server 8080  # Use port 8080 instead
```
Then visit: `http://localhost:8080`

### Use Different Backend Port:
Edit `backend/main.py` last line:
```python
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=9000)  # Use 9000
```

Edit `frontend/script.js` first line:
```javascript
const API_BASE_URL = 'http://localhost:9000';  // Match backend port
```

### Enable Backend Debug Logs:
Edit `backend/main.py`:
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

---

## 📊 Project Structure

```
amu_project/
├── backend/
│   └── main.py                 # FastAPI server (handles game logic)
│
├── frontend/
│   ├── index.html              # Game UI structure
│   ├── style.css               # Beautiful styling & animations
│   └── script.js               # Game logic & API calls
│
├── README.md                   # Full documentation
├── SETUP.md                    # This file
├── requirements.txt            # Python dependencies
├── start-game.ps1              # Auto-start script (PowerShell)
├── start.bat                   # Auto-start script (Batch)
└── .env.example                # Configuration template
```

---

## API Endpoints (For Developers)

### All endpoints accessible at: `http://localhost:8000`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Server status |
| GET | `/scene/{id}` | Get scene data (id: 1-5) |
| POST | `/submit-decision` | Submit choice (A/B/C) |
| GET | `/final-result` | Get game results |
| POST | `/reset-game` | Reset game state |
| GET | `/docs` | API documentation (Swagger) |

---

## ✨ Features Implemented

✅ **5 Different Civic Scenarios**
✅ **3 Decision Options per Scene**
✅ **Dynamic Scoring (+20/-10 points)**
✅ **Real-time Score Updates**
✅ **Progress Bar Animation**
✅ **Beautiful UI with Gradients**
✅ **Smooth Transitions & Animations**
✅ **Decision Summary Display**
✅ **Civic Sense Rating System**
✅ **Game Restart Functionality**
✅ **Fully Responsive Design**
✅ **CORS-Enabled Backend**
✅ **API Documentation (Swagger)**

---

## 🎓 Learning

This project demonstrates:
- **Frontend:** HTML5, CSS3 Animations, Vanilla JavaScript, Fetch API
- **Backend:** FastAPI, Python, REST API Design, CORS
- **Architecture:** Client-Server, Request-Response, State Management
- **DevOps:** HTTP Servers, Port Management, Process Management

---

## 📞 Need Help?

1. **Read the error message carefully** - Usually very helpful
2. **Check both PowerShell windows** - Is backend/frontend running?
3. **Open DevTools** (F12 in browser) - Check for errors
4. **Network Tab** (DevTools) - See if API calls succeed
5. **Review README.md** - Full documentation available

---

## 🎉 Ready to Play?

```powershell
# Run this in PowerShell (as Administrator):
cd "c:\Users\Acer\OneDrive\Desktop\projects\amu_project"
powershell -ExecutionPolicy Bypass -File start-game.ps1
```

**The game will open automatically!** 🏙️✨

---

**Enjoy CityTrack: Civic Sense Simulator!**
