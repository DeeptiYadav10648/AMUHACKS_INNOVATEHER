# Player.gd
# Player character controller for the civic sense simulation
# - Handles WASD/Arrow key movement in 2D world
# - Maintains collision with the environment  
# - Detects proximity to civic issues via Area2D
# - Triggers scenario popup on "E" key press
# - Manages player visual representation

extends CharacterBody2D

## Player movement speed in pixels per second
@export var speed: float = 200.0

## Player acceleration factor
@export var acceleration: float = 1500.0

## Reference to the detection area for finding nearby civic issues
@onready var detection_area = $InteractionArea

## Called when scene is ready
func _ready() -> void:
	print("Player initialized at position: ", position)
	add_to_group("player")

## Called every frame for physics updates
func _physics_process(delta: float) -> void:
	# Get input from player
	var input_velocity = get_input_velocity()
	
	# Apply acceleration
	if input_velocity.length() > 0:
		velocity = velocity.move_toward(input_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	
	# Move the character using built-in physics
	move_and_slide()

## Get the input velocity based on player input
func get_input_velocity() -> Vector2:
	var input_vec = Vector2.ZERO
	
	# WASD or Arrow keys
	if Input.is_action_pressed("ui_right"):
		input_vec.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vec.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vec.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vec.y -= 1
	
	# Normalize to prevent faster diagonal movement
	if input_vec.length() > 0:
		input_vec = input_vec.normalized() * speed
	
	return input_vec

## Called on interact input - tries to interact with nearby civic issue
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		# Find the first civic issue in the detection area
		var overlapping_areas = detection_area.get_overlapping_areas()
		for area in overlapping_areas:
			if area.name == "CivicIssue" or area.is_in_group("civic_issue"):
				# Call the show_scenario method if it exists
				if area.has_method("show_scenario"):
					area.show_scenario()
					break
