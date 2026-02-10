extends Control

# Simple frontend logic to create player via backend API
onready var name_input = $NameLineEdit
onready var background_select = $BackgroundOption
onready var create_btn = $CreateButton
onready var http = $HTTPRequest

const BACKEND_BASE := "http://127.0.0.1:8000/api"

func _ready():
    background_select.add_item("Student")
    background_select.add_item("Worker")
    background_select.add_item("Retiree")
    background_select.add_item("Educator")
    create_btn.connect("pressed", self, "on_create_pressed")
    http.connect("request_completed", self, "_on_request_completed")

func on_create_pressed():
    var name = name_input.text.strip()
    if name == "":
        print("Please enter a name")
        return
    var background = background_select.get_item_text(background_select.get_selected())
    var payload = {"name": name, "background": background, "avatar": null}
    var json_data = to_json(payload)
    
    # POST to backend to create profile
    var url = BACKEND_BASE + "/players/"
    var headers = ["Content-Type: application/json"]
    http.request(url, headers, true, HTTPClient.METHOD_POST, json_data)
    create_btn.disabled = true

func _on_request_completed(result, response_code, headers, body):
    create_btn.disabled = false
    if response_code >= 200 and response_code < 300:
        var text = body.get_string_from_utf8()
        var data = parse_json(text)
        if typeof(data) == TYPE_DICTIONARY and data.has("id"):
            # Store player id in autoload GameState and move to Scenario scene
            if Engine.has_singleton("GameState"):
                var gs = Engine.get_singleton("GameState")
                gs.player_id = data.id
                print("Player created with ID: ", data.id)
            else:
                print("GameState autoload not found; player id:", data.id)
            get_tree().change_scene("res://scenes/Scenario.tscn")
        else:
            print("Unexpected response shape:", text)
    else:
        var text = body.get_string_from_utf8()
        print("Create player failed, HTTP %d: %s" % [response_code, text])
