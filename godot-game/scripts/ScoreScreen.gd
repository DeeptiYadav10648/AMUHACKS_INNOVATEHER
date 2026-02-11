# ScoreScreen.gd
# Displays the end-game score screen
# - Shows final civic score
# - Shows civic level based on score
# - Provides restart button to reset and reload game
# - Reads from GameManager singleton

extends Control

## Called when scene is ready
func _ready() -> void:
	# Get score from GameManager
	var final_score = GameManager.get_score()
	var civic_level = GameManager.get_civic_level()
	
	# Update UI elements
	var score_label = get_node("CanvasLayer/Panel/VBoxContainer/ScoreLabel")
	var level_label = get_node("CanvasLayer/Panel/VBoxContainer/LevelLabel")
	var restart_button = get_node("CanvasLayer/Panel/VBoxContainer/RestartButton")
	
	score_label.text = "Final Civic Score: " + str(final_score)
	level_label.text = "Civic Level: " + civic_level
	
	# Connect restart button
	restart_button.pressed.connect(_on_restart_pressed)
	
	print("Score Screen displayed - Score: ", final_score, " Level: ", civic_level)

## Called when restart button is pressed
func _on_restart_pressed() -> void:
	# Reset the score
	GameManager.reset_score()
	
	# Reload the main game scene
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
	
	print("Game restarted")
