// CityTrack - Civic Sense Simulator (Phaser Edition)
// Configuration
const API_BASE = 'http://localhost:3001/api';

let gameState = {
  score: 0,
  completedIssues: 0,
  issues: {},
  interactedIssues: new Set(),
  currentlyNearIssue: null
};

// Phaser Config
const gameConfig = {
  type: Phaser.AUTO,
  width: window.innerWidth,
  height: window.innerHeight,
  parent: 'game-container',
  physics: {
    default: 'arcade',
    arcade: {
      gravity: { y: 0 },
      debug: false
    }
  },
  scene: {
    preload: preload,
    create: create,
    update: update
  },
  scale: {
    fullscreenTarget: 'game-container',
    expandParent: true
  }
};

let gameInstance = null;

// Create Game after DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    gameInstance = new Phaser.Game(gameConfig);
  });
} else {
  gameInstance = new Phaser.Game(gameConfig);
}

function preload() {
  // No assets to preload
}

function create() {
  const scene = this;
  
  // Set canvas background color
  scene.cameras.main.setBackgroundColor('#87ceeb');
  
  // Draw simple city background
  const graphics = scene.add.graphics();
  
  // Sky background
  graphics.fillStyle(0x87ceeb, 1);
  graphics.fillRect(0, 0, 1200, 800);
  
  // Green park areas
  graphics.fillStyle(0x228B22, 1);
  graphics.fillRect(50, 50, 300, 200);
  graphics.fillRect(800, 500, 350, 250);
  
  // Road
  graphics.fillStyle(0x333333, 1);
  graphics.fillRect(0, 350, 1200, 100);
  
  // Road markings
  graphics.fillStyle(0xFFFF00, 1);
  for (let x = 0; x < 1200; x += 60) {
    graphics.fillRect(x, 395, 40, 10);
  }
  
  // Buildings
  graphics.fillStyle(0xCC6633, 1);
  graphics.fillRect(100, 500, 200, 200);
  graphics.fillRect(600, 100, 250, 180);
  graphics.fillRect(400, 550, 150, 150);
  
  // Windows
  graphics.fillStyle(0xFFFF00, 1);
  for (let i = 0; i < 3; i++) {
    for (let j = 0; j < 4; j++) {
      graphics.fillRect(110 + i * 55, 510 + j * 40, 30, 30);
      graphics.fillRect(610 + i * 65, 110 + j * 40, 40, 30);
    }
  }
  
  // Player
  const playerGraphics = scene.add.graphics();
  playerGraphics.fillStyle(0xFF0000, 1);
  playerGraphics.fillCircle(12, 12, 12);
  playerGraphics.generateTexture('player', 24, 24);
  playerGraphics.destroy();
  
  const player = scene.physics.add.sprite(200, 200, 'player');
  player.setCollideWorldBounds(true);
  player.setBounce(0, 0);
  
  scene.player = player;
  scene.cameras.main.startFollow(player);
  scene.cameras.main.setBounds(0, 0, 1200, 800);
  
  // Input handling
  scene.cursors = scene.input.keyboard.createCursorKeys();
  scene.input.keyboard.on('keydown-E', () => {
    if (gameState.currentlyNearIssue && !gameState.interactedIssues.has(gameState.currentlyNearIssue.id)) {
      showDecisionModal(gameState.currentlyNearIssue);
    }
  });
  
  // Load issues
  loadIssuesFromAPI(scene);
}

function update() {
  const scene = this;
  if (!scene.player || !scene.cursors) return;
  
  scene.player.setVelocity(0, 0);
  const speed = 150;
  
  if (scene.cursors.left.isDown) scene.player.setVelocityX(-speed);
  else if (scene.cursors.right.isDown) scene.player.setVelocityX(speed);
  
  if (scene.cursors.up.isDown) scene.player.setVelocityY(-speed);
  else if (scene.cursors.down.isDown) scene.player.setVelocityY(speed);
  
  // Check proximity to issues
  updateIssueProximity(scene, scene.player);
}

async function loadIssuesFromAPI(scene) {
  try {
    const resp = await fetch(API_BASE + '/issues');
    const issues = await resp.json();
    gameState.issues = issues;
    
    Object.values(issues).forEach(issue => {
      if (gameState.interactedIssues.has(issue.id)) return;
      
      const container = scene.add.container(issue.x, issue.y);
      const circle = scene.add.circle(0, 0, 25, 0xFF6B6B);
      circle.setDepth(100);
      
      const emoji = scene.add.text(0, 0, issue.emoji, { fontSize: '24px' });
      emoji.setOrigin(0.5, 0.5);
      emoji.setDepth(101);
      
      container.add([circle, emoji]);
      container.setDepth(100);
      container.setDepth(100);
      
      // Blink animation
      scene.tweens.add({
        targets: circle,
        alpha: { from: 1, to: 0.3 },
        duration: 800,
        repeat: -1,
        yoyo: true
      });
      
      container.isIssue = true;
      container.id = issue.id;
      container.issueName = issue.name;
      container.issueEmoji = issue.emoji;
      container.issueDesc = issue.description;
    });
  } catch (error) {
    console.error('Error loading issues:', error);
  }
}

function updateIssueProximity(scene, player) {
  let nearest = null;
  let minDist = 100;
  
  scene.children.list.forEach(child => {
    if (child.isIssue && !gameState.interactedIssues.has(child.id)) {
      const dist = Phaser.Math.Distance.Between(player.x, player.y, child.x, child.y);
      if (dist < minDist) {
        minDist = dist;
        nearest = child;
      }
    }
  });
  
  gameState.currentlyNearIssue = nearest;
  
  const hint = document.getElementById('interaction-hint');
  if (nearest) {
    if (!hint) {
      const newHint = document.createElement('div');
      newHint.id = 'interaction-hint';
      newHint.style.cssText = 'position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%); background: rgba(0,0,0,0.8); color: white; padding: 12px 24px; border-radius: 8px; z-index: 999;';
      document.body.appendChild(newHint);
    }
    document.getElementById('interaction-hint').textContent = `Press E - ${nearest.issueName} ${nearest.issueEmoji}`;
    document.getElementById('interaction-hint').style.display = 'block';
  } else if (hint) {
    hint.style.display = 'none';
  }
}

function closeDecisionModal() {
  const modal = document.getElementById('decision-modal');
  if (modal) {
    modal.remove();
  }
  // Remove escape listener
  document.removeEventListener('keydown', handleModalEscape);
}

function handleModalEscape(e) {
  if (e.key === 'Escape') {
    closeDecisionModal();
  }
}

function showDecisionModal(issue) {
  const overlay = document.createElement('div');
  overlay.id = 'decision-modal';
  overlay.style.cssText = 'position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 2000;';
  
  const modal = document.createElement('div');
  modal.style.cssText = 'background: white; border-radius: 15px; padding: 40px; max-width: 600px; width: 90%; box-shadow: 0 10px 40px rgba(0,0,0,0.3);';
  
  modal.innerHTML = `
    <div style="text-align: center;">
      <div style="font-size: 50px; margin-bottom: 15px;">${issue.issueEmoji}</div>
      <h2 style="color: #2d5f7d; margin-bottom: 10px;">${issue.issueName}</h2>
      <p style="color: #666; margin-bottom: 30px;">${issue.issueDesc}</p>
      <div style="display: flex; flex-direction: column; gap: 12px;">
        <button onclick="submitDecision(${issue.id}, 'fix')" style="padding: 15px; border: none; border-radius: 8px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; font-weight: 600; cursor: pointer;">A) Fix it yourself (+20)</button>
        <button onclick="submitDecision(${issue.id}, 'report')" style="padding: 15px; border: none; border-radius: 8px; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; font-weight: 600; cursor: pointer;">B) Report it (+10)</button>
        <button onclick="submitDecision(${issue.id}, 'ignore')" style="padding: 15px; border: none; border-radius: 8px; background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; font-weight: 600; cursor: pointer;">C) Ignore it (-10)</button>
      </div>
      <p style="color: #999; font-size: 0.9rem; margin-top: 20px;">Press ESC or click outside to cancel</p>
    </div>
  `;
  
  overlay.appendChild(modal);
  document.body.appendChild(overlay);
  
  // Close on overlay click (outside modal)
  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) {
      closeDecisionModal();
    }
  });
  
  // Close on ESC key
  document.addEventListener('keydown', handleModalEscape);
}

window.submitDecision = async function(issueId, decision) {
  try {
    const response = await fetch(API_BASE + '/submit-decision', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ issueId, decision })
    });
    
    const data = await response.json();
    gameState.interactedIssues.add(issueId);
    gameState.score = data.totalScore;
    gameState.completedIssues = data.completedIssues;
    
    // Update score display
    updateScoreDisplay();
    
    // Remove issue from scene
    if (gameInstance) {
      const scene = gameInstance.scene.getActive();
      scene.children.list.forEach(child => {
        if (child.isIssue && child.id === issueId) {
          child.destroy();
        }
      });
    }
    
    // Close modal
    closeDecisionModal();
    
    // Check if game over
    if (!data.gameActive) {
      showResultsScreen();
    }
  } catch (error) {
    console.error('Decision error:', error);
  }
};

function updateScoreDisplay() {
  let scoreDisplay = document.getElementById('score-display');
  if (!scoreDisplay) {
    scoreDisplay = document.createElement('div');
    scoreDisplay.id = 'score-display';
    scoreDisplay.style.cssText = 'position: fixed; top: 20px; left: 20px; background: rgba(255,255,255,0.95); padding: 15px 25px; border-radius: 10px; z-index: 100; font-weight: 600;';
    document.body.appendChild(scoreDisplay);
  }
  scoreDisplay.innerHTML = `<div>Score: <span style="color: #3a8968; font-size: 1.5rem;">${gameState.score}</span></div><div style="color: #666; font-size: 0.9rem;">Issues: ${gameState.completedIssues}/5</div>`;
}

async function showResultsScreen() {
  try {
    const response = await fetch(API_BASE + '/final-result');
    const result = await response.json();
    
    const overlay = document.createElement('div');
    overlay.style.cssText = 'position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: linear-gradient(135deg, #2d5f7d 0%, #3a8968 100%); display: flex; align-items: center; justify-content: center; z-index: 3000;';
    
    let rating = result.rating;
    let ratingColor = '#3a8968';
    if (result.score >= 80) ratingColor = '#27ae60';
    else if (result.score < 50) ratingColor = '#e74c3c';
    
    const content = document.createElement('div');
    content.style.cssText = 'background: white; border-radius: 20px; padding: 50px; max-width: 700px; width: 90%; text-align: center;';
    content.innerHTML = `
      <h1 style="color: #2d5f7d; font-size: 2.5rem; margin-bottom: 10px;">GAME COMPLETE!</h1>
      <p style="color: #3a8968; font-size: 1.2rem; margin-bottom: 30px;">Your Civic Sense Report</p>
      <div style="font-size: 4rem; font-weight: bold; color: #3a8968; margin-bottom: 10px;">${result.score}</div>
      <p style="color: #666; margin-bottom: 30px;">out of 100</p>
      <h2 style="color: ${ratingColor}; font-size: 2rem; margin-bottom: 15px;">${rating}</h2>
      <p style="color: #666; font-size: 1.1rem; margin-bottom: 30px;">${result.message}</p>
      <button onclick="location.reload()" style="padding: 18px 40px; font-size: 1.1rem; font-weight: bold; border: none; border-radius: 10px; background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%); color: white; cursor: pointer; text-transform: uppercase;">Play Again</button>
    `;
    
    overlay.appendChild(content);
    document.body.appendChild(overlay);
  } catch (error) {
    console.error('Results error:', error);
  }
}

// Initialize
window.addEventListener('load', async () => {
  console.log('CityTrack Phaser Edition loaded');
  updateScoreDisplay();
  
  try {
    await fetch(API_BASE + '/new-game', { method: 'POST' });
    console.log('Game initialized');
  } catch (error) {
    console.warn('Backend initialization:', error.message);
  }
});
