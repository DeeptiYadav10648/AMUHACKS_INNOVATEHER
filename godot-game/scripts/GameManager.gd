# GameManager.gd
# Global singleton for managing the civic sense simulation game
# - Tracks civic score throughout the game
# - Provides API for updating score based on player decisions
# - Maintains game state across scenes

extends Node

## The current civic sense score
var civic_score: int = 0

## Called when the scene tree is ready
func _ready():
	print("GameManager initialized with score: ", civic_score)

## Update the civic score with given points
## Called by ScenarioPopup when player makes a decision
func update_score(points: int) -> void:
	civic_score += points
	print("Civic Score updated by ", points, ". Current Score: ", civic_score)

## Reset the civic score to 0
## Called when starting a new game or restarting
func reset_score() -> void:
	civic_score = 0
	print("Civic Score reset to 0")

## Get the current civic score
## Used by ScoreScreen to display final score
func get_score() -> int:
	return civic_score

## Get the civic level based on current score
## Used by ScoreScreen to determine citizen level
func get_civic_level() -> String:
	if civic_score >= 80:
		return "Responsible Citizen"
	elif civic_score >= 50:
		return "Aware Citizen"
	else:
		return "Needs Improvement"
