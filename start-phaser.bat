@echo off
REM CityTrack Phaser Edition - Quick Start for Windows

echo.
echo ================================================
echo   CityTrack: Civic Sense Simulator
echo   Phaser Interactive Edition
echo ================================================
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js not found!
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

echo Detected: 
node --version

echo.
echo Installing dependencies...
echo.

REM Install backend dependencies
echo [1/4] Installing backend dependencies...
cd backend
call npm install >nul 2>&1
cd ..

REM Install frontend dependencies
echo [2/4] Installing frontend dependencies...
cd frontend
call npm install >nul 2>&1
cd ..

echo.
echo ================================================
echo Starting servers...
echo ================================================
echo.

REM Start backend in new window
echo [3/4] Starting Backend Server (port 3001)...
start "CityTrack Backend" cmd /k "cd backend && npm start"
timeout /t 2 /nobreak

REM Start frontend in new window
echo [4/4] Starting Frontend Server (port 5500)...
start "CityTrack Frontend" cmd /k "cd frontend && npm start"
timeout /t 2 /nobreak

REM Open browser
echo.
echo Opening game in browser...
timeout /t 2 /nobreak

start http://localhost:5500

echo.
echo ================================================
echo SUCCESS! Game is loading...
echo ================================================
echo.
echo Backend:  http://localhost:3001
echo Frontend: http://localhost:5500
echo.
echo Controls:
echo   Arrow Keys = Move
echo   E Key = Interact
echo.
echo Keep both terminal windows open!
echo.
pause
