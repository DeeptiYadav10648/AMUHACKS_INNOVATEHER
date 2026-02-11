# CityTrack Phaser Edition - PowerShell Startup Script
# Run as: powershell -ExecutionPolicy Bypass -File start-phaser.ps1

Clear-Host

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  CityTrack: Civic Sense Simulator" -ForegroundColor Cyan
Write-Host "  Phaser Interactive Edition" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check Node.js
Write-Host "[1/5] Checking Node.js..." -ForegroundColor Yellow
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    Write-Host "ERROR: Node.js not found!" -ForegroundColor Red
    Write-Host "Install from: https://nodejs.org/" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}
Write-Host "OK: $(node --version)" -ForegroundColor Green

# Install backend
Write-Host "[2/5] Installing backend dependencies..." -ForegroundColor Yellow
Push-Location "backend"
npm install --silent
Pop-Location
Write-Host "OK: Backend ready" -ForegroundColor Green

# Install frontend
Write-Host "[3/5] Installing frontend dependencies..." -ForegroundColor Yellow
Push-Location "frontend"
npm install --silent
Pop-Location
Write-Host "OK: Frontend ready" -ForegroundColor Green
Write-Host ""

# Start servers
Write-Host "[4/5] Starting servers..." -ForegroundColor Yellow

$backendProcess = Start-Process -FilePath npm -ArgumentList "start" -WorkingDirectory "backend" -WindowStyle Minimized -PassThru
Write-Host "OK: Backend started (PID: $($backendProcess.Id))" -ForegroundColor Green

Start-Sleep -Seconds 2

$frontendProcess = Start-Process -FilePath npm -ArgumentList "start" -WorkingDirectory "frontend" -WindowStyle Minimized -PassThru
Write-Host "OK: Frontend started (PID: $($frontendProcess.Id))" -ForegroundColor Green
Write-Host ""

# Open browser
Write-Host "[5/5] Opening game..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
Start-Process "http://localhost:5500"

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "SUCCESS! Game is loading..." -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Backend:  http://localhost:3001" -ForegroundColor Cyan
Write-Host "Frontend: http://localhost:5500" -ForegroundColor Cyan
Write-Host ""
Write-Host "Controls:" -ForegroundColor Yellow
Write-Host "  Arrow Keys = Move" -ForegroundColor White
Write-Host "  E Key = Interact" -ForegroundColor White
Write-Host ""
Write-Host "Close this window to stop both servers." -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to continue"

Write-Host "Stopping servers..." -ForegroundColor Yellow
Stop-Process -Id $backendProcess.Id -Force -ErrorAction SilentlyContinue
Stop-Process -Id $frontendProcess.Id -Force -ErrorAction SilentlyContinue
Write-Host "Servers stopped." -ForegroundColor Green
