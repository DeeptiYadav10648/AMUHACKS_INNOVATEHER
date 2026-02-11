# CityTrack Quick Start Script for Windows PowerShell
# This script will start both backend and frontend servers

Clear-Host
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "CityTrack: Civic Sense Simulator" -ForegroundColor Cyan
Write-Host "Quick Start" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check Python
Write-Host "[1/4] Checking Python installation..." -ForegroundColor Yellow
$pythonCheck = & python --version
Write-Host "[OK] Python found: $pythonCheck" -ForegroundColor Green
Write-Host ""

# Install dependencies
Write-Host "[2/4] Installing dependencies..." -ForegroundColor Yellow
& pip install -r requirements.txt -q
Write-Host "[OK] Dependencies installed successfully" -ForegroundColor Green
Write-Host ""

# Start Backend
Write-Host "[3/4] Starting FastAPI Backend..." -ForegroundColor Yellow
$backendProcess = Start-Process -FilePath python -ArgumentList "backend/main.py" -PassThru -WindowStyle Minimized
Write-Host "[OK] Backend started (PID: $($backendProcess.Id))" -ForegroundColor Green
Start-Sleep -Seconds 2
Write-Host ""

# Start Frontend server
Write-Host "[4/4] Starting Frontend Server..." -ForegroundColor Yellow
Push-Location "frontend"
$frontendProcess = Start-Process -FilePath python -ArgumentList "-m http.server 5500" -PassThru -WindowStyle Minimized
Pop-Location
Write-Host "[OK] Frontend started (PID: $($frontendProcess.Id))" -ForegroundColor Green
Write-Host ""

# Open browser
Write-Host "=====================================" -ForegroundColor Green
Write-Host "GAME IS READY!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Opening game in browser..." -ForegroundColor Cyan
Write-Host ""
Start-Sleep -Seconds 1
Start-Process "http://localhost:5500"

Write-Host "API Documentation: http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "To stop the game:" -ForegroundColor Yellow
Write-Host "   - Close this window, or" -ForegroundColor Yellow
Write-Host "   - Press Ctrl+C" -ForegroundColor Yellow
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan

# Wait for user to close
Read-Host "Press Enter to stop the game"

# Cleanup
Write-Host ""
Write-Host "Stopping servers..." -ForegroundColor Yellow
Stop-Process -Id $backendProcess.Id -Force -ErrorAction SilentlyContinue
Stop-Process -Id $frontendProcess.Id -Force -ErrorAction SilentlyContinue
Write-Host "[OK] Servers stopped" -ForegroundColor Green
Write-Host ""
Write-Host "Thank you for playing CityTrack!" -ForegroundColor Cyan
