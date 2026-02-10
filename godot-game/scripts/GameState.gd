extends Node

# Autoload singleton to hold player and game state across scenes
var player_id: int = null
var civic_scores = {"community_harmony": 0, "personal_integrity": 0, "social_capital": 0}

const BACKEND_BASE := "http://127.0.0.1:8001/api"

func update_scores(new_scores: Dictionary):
    for k in new_scores.keys():
        civic_scores[k] = new_scores[k]
