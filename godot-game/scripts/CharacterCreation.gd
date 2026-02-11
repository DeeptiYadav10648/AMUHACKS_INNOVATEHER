extends Control

@onready var name_input = $NameLineEdit
@onready var background_select = $BackgroundOption
@onready var create_btn = $CreateButton
@onready var http = $HTTPRequest

const BACKEND_BASE := "http://127.0.0.1:8000/api"

func _ready():
	background_select.add_item("Student")
	background_select.add_item("Worker")
	background_select.add_item("Retiree")
	background_select.add_item("Educator")

	create_btn.pressed.connect(on_create_pressed)
	http.request_completed.connect(_on_request_completed)

func on_create_pressed():
	var name = name_input.text.strip_edges()
	
	if name == "":
		print("Please enter a name")
		return

	var background = background_select.get_item_text(
		background_select.get_selected_id()
	)

	var payload = {
		"name": name,
		"background": background,
		"avatar": null
	}

	var json_data = JSON.stringify(payload)

	var url = BACKEND_BASE + "/players/"
	var headers = ["Content-Type: application/json"]

	http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json_data
	)

	create_btn.disabled = true


func _on_request_completed(result, response_code, headers, body):
	create_btn.disabled = false

	if response_code >= 200 and response_code < 300:
		var text = body.get_string_from_utf8()
		var data = JSON.parse_string(text)

		if typeof(data) == TYPE_DICTIONARY and data.has("id"):
			if Engine.has_singleton("GameState"):
				var gs = Engine.get_singleton("GameState")
				gs.player_id = data["id"]
				print("Player created with ID: ", data["id"])
			else:
				print("GameState autoload not found; player id:", data["id"])

			get_tree().change_scene_to_file("res://scenes/Scenario.tscn")
		else:
			print("Unexpected response shape:", text)
	else:
		var text = body.get_string_from_utf8()
		print("Create player failed, HTTP %d: %s" % [response_code, text])
