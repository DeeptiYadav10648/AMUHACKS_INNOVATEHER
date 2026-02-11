#!/bin/bash
# CityTrack Quick Start Script for Windows (PowerShell)

echo "======================================"
echo "CityTrack: Civic Sense Simulator"
echo "Quick Start Guide"
echo "======================================"
echo ""

# Check Python
echo "[1/3] Checking Python installation..."
python --version
if ($LASTEXITCODE -ne 0) {
    echo "ERROR: Python not found. Please install Python 3.8+ first"
    exit 1
}

echo ""
echo "[2/3] Installing dependencies..."
pip install -r requirements.txt

echo ""
echo "[3/3] Starting FastAPI backend server..."
echo ""
echo "✅ Backend starting on http://localhost:8000"
echo "✅ API Documentation: http://localhost:8000/docs"
echo ""
echo "⏳ Keep this window open while playing!"
echo ""
echo "[NEXT STEP] Open another PowerShell window and run:"
echo "  cd frontend"
echo "  python -m http.server 5500"
echo ""
echo "Then visit: http://localhost:5500"
echo ""
echo "======================================"

python backend/main.py
