# GarbageIssue.gd
# Represents a civic issue in the world (e.g., overflowing garbage bin)
# - Detects when player enters/exits collision area
# - Displays visual indication when player is near
# - Triggers scenario popup when player presses "E"
# - Connects to GameManager to handle scoring

extends Area2D

## Reference to the scenario popup scene
@onready var popup_scene = preload("res://scenes/ScenarioPopup.tscn")

## Flag to track if player is in range
var player_in_range: bool = false

## Reference to the popup instance
var popup_instance: Control = null

## Called when scene is ready
func _ready() -> void:
	print("GarbageIssue spawned at position: ", position)
	
	# Connect signals
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

## Called when area_entered signal is triggered (player enters range)
func _on_area_entered(area: Area2D) -> void:
	if area.name == "Player" or area.is_in_group("player"):
		player_in_range = true
		print("Player entered garbage issue range")

## Called when area_exited signal is triggered (player exits range)
func _on_area_exited(area: Area2D) -> void:
	if area.name == "Player" or area.is_in_group("player"):
		player_in_range = false
		print("Player left garbage issue range")

## Called every frame
func _process(_delta: float) -> void:
	# Check for player interaction
	if player_in_range and Input.is_action_just_pressed("interact"):
		show_scenario()

## Show the scenario popup with garbage bin options
func show_scenario() -> void:
	# Create popup instance
	popup_instance = popup_scene.instantiate()
	get_tree().root.add_child(popup_instance)
	
	# Setup the scenario
	var description = "Garbage is overflowing from the bin. What should you do?"
	var options = [
		{
			"text": "Pick up garbage",
			"score": 10
		},
		{
			"text": "Call municipality",
			"score": 7
		},
		{
			"text": "Ignore",
			"score": -5
		}
	]
	
	popup_instance.setup_scenario(description, options)
	popup_instance.parent_ref = get_parent()
	popup_instance.civic_issue_ref = self
	
	print("Garbage issue scenario shown")
