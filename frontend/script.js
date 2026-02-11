// Configuration
const API_BASE_URL = 'http://localhost:8000';
const SCENES_PER_GAME = 5;

// State
let gameState = {
    currentScene: 1,
    score: 0,
    completedScenes: 0,
    gameActive: true,
    decisions: []
};

// DOM Elements
const screens = {
    loading: document.getElementById('loadingScreen'),
    start: document.getElementById('startScreen'),
    game: document.getElementById('gameScreen'),
    result: document.getElementById('resultScreen')
};

const gameElements = {
    scoreDisplay: document.getElementById('scoreDisplay'),
    progressLabel: document.getElementById('progressLabel'),
    progressFill: document.getElementById('progressFill'),
    sceneEmoji: document.getElementById('sceneEmoji'),
    sceneTitle: document.getElementById('sceneTitle'),
    sceneDescription: document.getElementById('sceneDescription'),
    optionAText: document.getElementById('optionAText'),
    optionBText: document.getElementById('optionBText'),
    optionCText: document.getElementById('optionCText'),
    decisionA: document.getElementById('decisionA'),
    decisionB: document.getElementById('decisionB'),
    decisionC: document.getElementById('decisionC'),
};

const resultElements = {
    finalScore: document.getElementById('finalScore'),
    ratingTitle: document.getElementById('ratingTitle'),
    ratingMessage: document.getElementById('ratingMessage'),
    summaryList: document.getElementById('summaryList'),
};

// Button Event Listeners
document.getElementById('startBtn').addEventListener('click', startGame);
document.getElementById('restartBtn').addEventListener('click', restartGame);
document.getElementById('homeBtn').addEventListener('click', goHome);

gameElements.decisionA.addEventListener('click', () => submitDecision('A'));
gameElements.decisionB.addEventListener('click', () => submitDecision('B'));
gameElements.decisionC.addEventListener('click', () => submitDecision('C'));

// Initialize game on load
document.addEventListener('DOMContentLoaded', () => {
    showScreen('loading');
    initializeGame();
});

// Show specific screen
function showScreen(screenName) {
    Object.values(screens).forEach(screen => screen.classList.remove('active'));
    if (screens[screenName]) {
        screens[screenName].classList.add('active');
    }
}

// Initialize game
async function initializeGame() {
    try {
        // Wait a bit to show loading screen
        await new Promise(resolve => setTimeout(resolve, 1500));
        
        // Reset game state
        const resetResponse = await fetch(`${API_BASE_URL}/reset-game`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        });

        if (resetResponse.ok) {
            showScreen('start');
        } else {
            console.error('Failed to initialize game');
            showScreen('start');
        }
    } catch (error) {
        console.error('Error initializing game:', error);
        showScreen('start');
    }
}

// Start the game
async function startGame() {
    gameState = {
        currentScene: 1,
        score: 0,
        completedScenes: 0,
        gameActive: true,
        decisions: []
    };

    showScreen('game');
    disableAllDecisions(false);
    await loadScene(1);
}

// Load a specific scene
async function loadScene(sceneId) {
    try {
        const response = await fetch(`${API_BASE_URL}/scene/${sceneId}`);
        const data = await response.json();

        if (data.error) {
            console.error('Error loading scene:', data.error);
            return;
        }

        const scene = data.scene;

        // Update UI
        gameElements.sceneEmoji.textContent = scene.background_emoji;
        gameElements.sceneTitle.textContent = scene.title;
        gameElements.sceneDescription.textContent = scene.description;

        gameElements.optionAText.textContent = scene.options.A;
        gameElements.optionBText.textContent = scene.options.B;
        gameElements.optionCText.textContent = scene.options.C;

        gameElements.scoreDisplay.textContent = data.current_score;
        gameState.score = data.current_score;

        // Update progress
        updateProgress(data.scene_number, data.total_scenes);

        // Enable all decision buttons
        disableAllDecisions(false);
    } catch (error) {
        console.error('Error loading scene:', error);
    }
}

// Submit a decision
async function submitDecision(option) {
    // Disable all buttons to prevent multiple submissions
    disableAllDecisions(true);

    try {
        const response = await fetch(`${API_BASE_URL}/submit-decision`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                scene_id: gameState.currentScene,
                decision: option
            })
        });

        const data = await response.json();

        if (data.error) {
            console.error('Error submitting decision:', data.error);
            disableAllDecisions(false);
            return;
        }

        // Store decision
        gameState.decisions.push({
            scene: gameState.currentScene,
            decision: option,
            points: data.points_earned
        });

        gameState.score = data.total_score;
        gameState.completedScenes = data.completed_scenes;
        gameState.currentScene = data.next_scene;
        gameState.gameActive = data.game_active;

        // Update score display with animation
        animateScoreUpdate(data.points_earned);

        // Wait a moment before proceeding
        await new Promise(resolve => setTimeout(resolve, 1000));

        // Check if game is over
        if (!gameState.gameActive) {
            await showFinalResult();
        } else {
            // Load next scene
            await loadScene(gameState.currentScene);
        }
    } catch (error) {
        console.error('Error submitting decision:', error);
        disableAllDecisions(false);
    }
}

// Animate score update
function animateScoreUpdate(points) {
    const scoreElement = gameElements.scoreDisplay;
    const oldScore = gameState.score - points;

    // Create floating text
    const floatingText = document.createElement('div');
    floatingText.style.cssText = `
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-size: 2rem;
        font-weight: bold;
        z-index: 1000;
        pointer-events: none;
    `;

    if (points > 0) {
        floatingText.textContent = `+${points}`;
        floatingText.style.color = '#3a8968';
    } else if (points < 0) {
        floatingText.textContent = `${points}`;
        floatingText.style.color = '#e74c3c';
    } else {
        floatingText.textContent = `${points}`;
        floatingText.style.color = '#f39c12';
    }

    document.body.appendChild(floatingText);

    // Animate floating text
    floatingText.animate([
        { opacity: 1, transform: 'translate(-50%, -50%) scale(1)' },
        { opacity: 0, transform: 'translate(-50%, -150px) scale(1.5)' }
    ], {
        duration: 1000,
        easing: 'ease-out'
    });

    // Remove floating text after animation
    setTimeout(() => floatingText.remove(), 1000);

    // Update score display
    scoreElement.textContent = gameState.score;
}

// Update progress bar
function updateProgress(current, total) {
    const percentage = (current / total) * 100;
    gameElements.progressFill.style.width = percentage + '%';
    gameElements.progressLabel.textContent = `Scene ${current}/${total}`;
}

// Disable/Enable all decision buttons
function disableAllDecisions(disabled) {
    gameElements.decisionA.disabled = disabled;
    gameElements.decisionB.disabled = disabled;
    gameElements.decisionC.disabled = disabled;
}

// Show final result
async function showFinalResult() {
    try {
        const response = await fetch(`${API_BASE_URL}/final-result`);
        const data = await response.json();

        // Update result screen
        resultElements.finalScore.textContent = data.score;
        resultElements.ratingTitle.textContent = data.rating;
        resultElements.ratingMessage.textContent = data.message;

        // Build decisions summary
        buildDecisionsSummary(data.decisions);

        // Show result screen
        showScreen('result');
    } catch (error) {
        console.error('Error getting final result:', error);
    }
}

// Build decisions summary
function buildDecisionsSummary(decisions) {
    const summaryHTML = decisions.map((decision, index) => {
        const sceneNames = {
            1: 'Garbage Overflow',
            2: 'Broken Streetlight',
            3: 'Pothole in Road',
            4: 'Water Leakage',
            5: 'Illegal Poster'
        };

        const optionNames = {
            'A': 'Take Direct Action',
            'B': 'Inform Authorities',
            'C': 'Ignore Problem'
        };

        let pointsClass = '';
        if (decision.points > 0) {
            pointsClass = 'points-positive';
        } else if (decision.points === 10) {
            pointsClass = 'points-neutral';
        } else {
            pointsClass = 'points-negative';
        }

        const pointsText = decision.points > 0 ? `+${decision.points}` : `${decision.points}`;

        return `
            <div class="summary-item">
                <span class="item-name">
                    Scene ${decision.scene_id}: ${sceneNames[decision.scene_id]} → ${optionNames[decision.decision]}
                </span>
                <span class="item-points ${pointsClass}">${pointsText}</span>
            </div>
        `;
    }).join('');

    resultElements.summaryList.innerHTML = summaryHTML;
}

// Restart game
async function restartGame() {
    showScreen('loading');
    await new Promise(resolve => setTimeout(resolve, 800));
    await startGame();
}

// Go home
function goHome() {
    showScreen('start');
}

// Error handling for fetch
function handleFetchError(error) {
    console.error('Fetch error:', error);
    // Optionally show user-friendly error message
    alert('An error occurred. Please check your connection and try again.');
}
