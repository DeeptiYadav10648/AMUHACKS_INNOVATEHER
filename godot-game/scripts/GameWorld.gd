# GameWorld.gd
# Controls the main game world scene
# - Initializes civic issues and player spawn
# - Updates score display HUD
# - Handles end game trigger (walking to goal area)
# - Transitions to score screen when game ends
# - Uses GameManager singleton for score tracking

extends Node2D

## Reference to the score label in UI
@onready var score_label = get_node("UI/ScoreLabel")

## Reference to the end game area
@onready var end_game_area = $EndGameArea

## Timer for updating score display
var update_timer: float = 0.0

## Called when scene is ready
func _ready() -> void:
	print("GameWorld initialized")
	
	# Connect end game area
	end_game_area.area_entered.connect(_on_end_game_area_entered)
	
	# Reset score for new game (optional - comment out if continuing previous game)
	# GameManager.reset_score()
	
	print("Civic issues spawned. Explore the world and interact with issues!")

## Called every frame to update UI
func _process(delta: float) -> void:
	update_timer += delta
	
	# Update score display every 0.1 seconds
	if update_timer >= 0.1:
		score_label.text = "Civic Score: " + str(GameManager.get_score())
		update_timer = 0.0

## Called when player enters the end game area
func _on_end_game_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") or area.name == "Player":
		print("Player reached end game area!")
		show_score_screen()

## Transition to the score screen
func show_score_screen() -> void:
	# Small delay to let interactions complete
	await get_tree().create_timer(0.5).timeout
	
	get_tree().change_scene_to_file("res://scenes/ScoreScreen.tscn")
