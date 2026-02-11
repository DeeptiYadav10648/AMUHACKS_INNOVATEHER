extends Control

@onready var harmony_bar = $HarmonyBar
@onready var integrity_bar = $IntegrityBar
@onready var social_bar = $SocialBar

@onready var description_label = $Description
@onready var choice1 = $Choice1
@onready var choice2 = $Choice2
@onready var choice3 = $Choice3
@onready var choice4 = $Choice4
@onready var score_hud = $ScoreHUD
@onready var http = $HTTPRequest
@onready var npc_label = $NPCDialogue

var scenarios = []
var current_scenario = null
var current_index = 0

const BACKEND_BASE := "http://127.0.0.1:8000/api"

func _ready():
	http.request_completed.connect(_on_request_completed)
	choice1.pressed.connect(func(): _on_choice_pressed(0))
	choice2.pressed.connect(func(): _on_choice_pressed(1))
	choice3.pressed.connect(func(): _on_choice_pressed(2))
	choice4.pressed.connect(func(): _on_choice_pressed(3))
	fetch_scenarios()
	update_score_hud()

func fetch_scenarios():
	var url = BACKEND_BASE + "/scenarios"
	http.request(url)

func _on_request_completed(result, response_code, headers, body):
	if response_code >= 200 and response_code < 300:
		var text = body.get_string_from_utf8()
		var data = JSON.parse_string(text)
		if data is Array and data.size() > 0:
			scenarios = data
			current_index = 0
			show_current_scenario()
		elif data is Dictionary and data.has("updated_scores"):
			handle_decision_response(data)
	else:
		print("HTTP error: ", response_code)

func show_current_scenario():
	if current_index >= scenarios.size():
		description_label.text = "No more scenarios - Game Loop Complete!"
		choice1.disabled = true
		choice2.disabled = true
		choice3.disabled = true
		choice4.disabled = true
		return

	current_scenario = scenarios[current_index]
	description_label.text = current_scenario.get("description", "")
	var choices = current_scenario.get("choices", [])

	choice1.text = choices[0].get("text", "") if choices.size() > 0 else ""
	choice1.visible = choices.size() > 0
	choice1.disabled = false

	choice2.text = choices[1].get("text", "") if choices.size() > 1 else ""
	choice2.visible = choices.size() > 1
	choice2.disabled = false

	choice3.text = choices[2].get("text", "") if choices.size() > 2 else ""
	choice3.visible = choices.size() > 2
	choice3.disabled = false

	choice4.text = choices[3].get("text", "") if choices.size() > 3 else ""
	choice4.visible = choices.size() > 3
	choice4.disabled = false

func _on_choice_pressed(choice_index):
	if current_scenario == null:
		return

	var choices = current_scenario.get("choices", [])
	if choice_index >= choices.size():
		return

	var choice = choices[choice_index]
	var player_id = null

	if Engine.has_singleton("GameState"):
		player_id = Engine.get_singleton("GameState").player_id

	if player_id == null:
		get_tree().change_scene_to_file("res://scenes/CharacterCreation.tscn")
		return

	choice1.disabled = true
	choice2.disabled = true
	choice3.disabled = true
	choice4.disabled = true

	var payload = {"player_id": player_id, "choice_id": choice.get("id")}
	var json_data = JSON.stringify(payload)
	var url = BACKEND_BASE + "/scenarios/%s/decide" % current_scenario.get("id")

	http.request(url, [], HTTPClient.METHOD_POST, json_data)

func handle_decision_response(data):
	var updated = data.get("updated_scores", {})

	if Engine.has_singleton("GameState"):
		var gs = Engine.get_singleton("GameState")
		gs.update_scores(updated)

	update_score_hud()
	npc_label.text = data.get("message", "Decision recorded!")

	await get_tree().create_timer(2.0).timeout

	current_index += 1
	show_current_scenario()

func update_score_hud():
	var gs = null

	if Engine.has_singleton("GameState"):
		gs = Engine.get_singleton("GameState")

	var scores = gs.civic_scores if gs else {
		"community_harmony": 0,
		"personal_integrity": 0,
		"social_capital": 0
	}

	var harmony = scores.get("community_harmony", 0)
	var integrity = scores.get("personal_integrity", 0)
	var social = scores.get("social_capital", 0)

	score_hud.text = "Harmony: %d | Integrity: %d | Social Capital: %d" % [
		harmony, integrity, social
	]

	harmony_bar.value = harmony
	integrity_bar.value = integrity
	social_bar.value = social
