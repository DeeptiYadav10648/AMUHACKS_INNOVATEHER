# ScenarioPopup.gd
# Handles the popup UI for civic issue scenarios
# - Displays scenario description and options
# - Manages option buttons with score values
# - Updates GameManager when player makes a decision
# - Closes popup and notifies parent after decision

extends Control

## Reference to the parent/owner of this popup (e.g., GameWorld scene)
var parent_ref: Node

## Reference to the civic issue that triggered this popup (for removal after interaction)
var civic_issue_ref: Node

## Called when scene is added to the tree
func _ready() -> void:
	# Make popup invisible initially
	visible = false
	print("ScenarioPopup ready")

## Setup the popup with scenario data
## Called by interaction system when player presses "E" near civic issue
## options is Array[Dictionary] with structure: [{ "text": "Option 1", "score": 10 }, ...]
func setup_scenario(description: String, options: Array) -> void:
	# Set the scenario description
	var desc_label = get_node("CanvasLayer/Panel/VBoxContainer/DescriptionLabel")
	desc_label.text = description
	
	# Get the options container
	var options_container = get_node("CanvasLayer/Panel/VBoxContainer/OptionsContainer")
	
	# Clear previous buttons
	for button in options_container.get_children():
		button.queue_free()
	
	# Create buttons for each option
	for i in range(options.size()):
		var option = options[i]
		var button = Button.new()
		button.text = option["text"]
		button.custom_minimum_size = Vector2(400, 50)
		
		# Capture option data in a closure
		var score = option["score"]
		button.pressed.connect(func(): _on_option_selected(score))
		
		options_container.add_child(button)
	
	# Show the popup
	visible = true
	print("Scenario popup displayed: ", description)

## Called when a button is pressed
func _on_option_selected(score: int) -> void:
	# Update the game score
	GameManager.update_score(score)
	
	# Remove the civic issue that was interacted with
	if civic_issue_ref and civic_issue_ref.is_in_tree():
		civic_issue_ref.queue_free()
	
	# Close the popup
	close_popup()
	
	print("Option selected with score: ", score)

## Close the popup
func close_popup() -> void:
	visible = false
	print("Popup closed")
