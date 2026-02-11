const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Game State Storage
let gameState = {
  score: 0,
  completedIssues: 0,
  decisions: [],
  gameActive: true,
  gameStarted: false
};

// Issues Database
const ISSUES = {
  1: {
    id: 1,
    name: 'Garbage Overflow',
    description: 'Garbage is overflowing from a public bin',
    x: 300,
    y: 200,
    emoji: '🗑️'
  },
  2: {
    id: 2,
    name: 'Broken Streetlight',
    description: 'A streetlight is not working',
    x: 600,
    y: 150,
    emoji: '💡'
  },
  3: {
    id: 3,
    name: 'Road Pothole',
    description: 'There is a pothole in the road',
    x: 400,
    y: 400,
    emoji: '🕳️'
  },
  4: {
    id: 4,
    name: 'Water Leakage',
    description: 'Water is leaking from a pipeline',
    x: 700,
    y: 350,
    emoji: '💧'
  },
  5: {
    id: 5,
    name: 'Illegal Poster',
    description: 'Wall has illegal advertising posters',
    x: 200,
    y: 500,
    emoji: '🎨'
  }
};

// Decision Scores
const DECISION_SCORES = {
  'fix': 20,         // Fix it yourself
  'report': 10,      // Report to authorities
  'ignore': -10      // Ignore
};

// --- API ENDPOINTS ---

// GET - Server Status
app.get('/', (req, res) => {
  res.json({ 
    message: 'CityTrack Backend - Phaser Edition',
    version: '2.0.0'
  });
});

// GET - Game State
app.get('/api/game-state', (req, res) => {
  res.json(gameState);
});

// GET - All Issues
app.get('/api/issues', (req, res) => {
  res.json(ISSUES);
});

// GET - Single Issue
app.get('/api/issue/:id', (req, res) => {
  const issue = ISSUES[req.params.id];
  if (issue) {
    res.json(issue);
  } else {
    res.status(404).json({ error: 'Issue not found' });
  }
});

// POST - Submit Decision
app.post('/api/submit-decision', (req, res) => {
  const { issueId, decision } = req.body;

  // Validate
  if (!issueId || !decision) {
    return res.status(400).json({ error: 'Missing issueId or decision' });
  }

  if (!ISSUES[issueId]) {
    return res.status(404).json({ error: 'Issue not found' });
  }

  if (!DECISION_SCORES[decision]) {
    return res.status(400).json({ error: 'Invalid decision type' });
  }

  // Calculate points
  const points = DECISION_SCORES[decision];
  gameState.score += points;
  gameState.completedIssues += 1;

  // Record decision
  gameState.decisions.push({
    issueId,
    issueName: ISSUES[issueId].name,
    decision,
    points,
    timestamp: new Date()
  });

  // Check if game is over
  if (gameState.completedIssues >= 5) {
    gameState.gameActive = false;
  }

  res.json({
    pointsEarned: points,
    totalScore: gameState.score,
    completedIssues: gameState.completedIssues,
    gameActive: gameState.gameActive,
    issueName: ISSUES[issueId].name
  });
});

// POST - Get Final Result
app.get('/api/final-result', (req, res) => {
  let rating = 'Needs Improvement';
  let message = 'Keep improving your civic responsibility!';

  if (gameState.score >= 80) {
    rating = 'Responsible Citizen';
    message = 'Excellent civic responsibility!';
  } else if (gameState.score >= 50) {
    rating = 'Aware Citizen';
    message = 'Good civic awareness, but can improve!';
  }

  res.json({
    score: gameState.score,
    rating,
    message,
    completedIssues: gameState.completedIssues,
    decisions: gameState.decisions
  });
});

// POST - Start New Game
app.post('/api/new-game', (req, res) => {
  gameState = {
    score: 0,
    completedIssues: 0,
    decisions: [],
    gameActive: true,
    gameStarted: true
  };

  res.json({ message: 'New game started', gameState });
});

// POST - Reset Game
app.post('/api/reset-game', (req, res) => {
  gameState = {
    score: 0,
    completedIssues: 0,
    decisions: [],
    gameActive: true,
    gameStarted: false
  };

  res.json({ message: 'Game reset' });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Start Server
app.listen(PORT, () => {
  console.log('');
  console.log('╔═══════════════════════════════════════╗');
  console.log('║   CityTrack - Backend Server (v2.0)   ║');
  console.log('╚═══════════════════════════════════════╝');
  console.log('');
  console.log(`✓ Server running on http://localhost:${PORT}`);
  console.log(`✓ API available at http://localhost:${PORT}/api/*`);
  console.log(`✓ CORS enabled`);
  console.log('');
});

module.exports = app;
