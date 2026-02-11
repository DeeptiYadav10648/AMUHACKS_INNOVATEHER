extends Node2D

func _ready():
	# Load CharacterCreation scene as child
	var cc = preload("res://scenes/CharacterCreation.tscn").instance()
	add_child(cc)
