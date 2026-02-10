extends Control

onready var description_label = $Description
onready var choice1 = $Choice1
onready var choice2 = $Choice2
onready var choice3 = $Choice3
onready var score_hud = $ScoreHUD
onready var http = $HTTPRequest
onready var npc_label = $NPCDialogue

var scenarios = []
var current_index = 0

const BACKEND_BASE := "http://127.0.0.1:8001/api"

func _ready():
    http.connect("request_completed", self, "_on_request_completed")
    choice1.connect("pressed", self, "_on_choice_pressed", [0])
    choice2.connect("pressed", self, "_on_choice_pressed", [1])
    choice3.connect("pressed", self, "_on_choice_pressed", [2])
    fetch_scenarios()
    update_score_hud()

func fetch_scenarios():
    var url = BACKEND_BASE + "/scenarios"
    http.request(url)

func _on_request_completed(result, response_code, headers, body):
    if response_code >= 200 and response_code < 300:
        var text = body.get_string_from_utf8()
        var data = parse_json(text)
        if typeof(data) == TYPE_ARRAY and data.size() > 0:
            scenarios = data
            current_index = 0
            show_current_scenario()
        else:
            print("No scenarios returned")
    else:
        print("HTTP error fetching scenarios:", response_code)

func show_current_scenario():
    if current_index >= scenarios.size():
        description_label.text = "No more scenarios"
        choice1.disabled = choice2.disabled = choice3.disabled = true
        return
    var s = scenarios[current_index]
    description_label.text = s.get('description', '')
    var ch = s.get('choices', [])
    # Fill buttons or hide if not available
    choice1.text = ch.size() > 0 ? ch[0].get('text', '') : ""
    choice1.visible = ch.size() > 0
    choice2.text = ch.size() > 1 ? ch[1].get('text', '') : ""
    choice2.visible = ch.size() > 1
    choice3.text = ch.size() > 2 ? ch[2].get('text', '') : ""
    choice3.visible = ch.size() > 2

func _on_choice_pressed(choice_index):
    var s = scenarios[current_index]
    var ch = s.get('choices', [])
    if choice_index >= ch.size():
        return
    var choice = ch[choice_index]
    # Submit decision to backend
    var player_id = null
    if Engine.has_singleton("GameState"):
        player_id = Engine.get_singleton("GameState").player_id
    if player_id == null:
        print("No player id — return to character creation")
        get_tree().change_scene("res://scenes/CharacterCreation.tscn")
        return
    var payload = {"player_id": player_id, "choice_id": choice.get('id')}
    var json_data = to_json(payload)
    var url = BACKEND_BASE + "/scenarios/%s/decide" % s.get('id')
    http.request(url, [], true, HTTPClient.METHOD_POST, json_data)

func handle_decision_response(data):
    # data expected to contain updated_scores and message
    var updated = data.get('updated_scores', {})
    var msg = data.get('message', '')
    # update autoload GameState
    if Engine.has_singleton("GameState"):
        var gs = Engine.get_singleton("GameState")
        gs.update_scores(updated)
    # update HUD and NPC reaction
    update_score_hud()
    npc_label.text = msg
    # simple progression: advance to next scenario
    current_index += 1
    show_current_scenario()

func update_score_hud():
    var gs = null
    if Engine.has_singleton("GameState"):
        gs = Engine.get_singleton("GameState")
    var s = gs ? gs.civic_scores : {"community_harmony":0, "personal_integrity":0, "social_capital":0}
    score_hud.text = "Harmony: %d  Integrity: %d  Social: %d" % [s.community_harmony, s.personal_integrity, s.social_capital]
extends Control

onready var desc = $Description
onready var c1 = $Choice1
onready var c2 = $Choice2
onready var c3 = $Choice3
onready var hud = $ScoreHUD

func _ready():
    # Placeholder text; in full app fetch scenario data from backend
    desc.text = "Scenario will appear here"
    c1.text = "Choice A"
    c2.text = "Choice B"
    c3.text = "Choice C"
    c1.connect("pressed", self, "on_choice", [1])
    c2.connect("pressed", self, "on_choice", [2])
    c3.connect("pressed", self, "on_choice", [3])
    update_hud(0,0,0)

func on_choice(choice_id):
    # TODO: send chosen id to backend and update HUD
    print("Chosen:", choice_id)

func update_hud(ch, pi, sc):
    hud.text = "Harmony: %d  Integrity: %d  Social: %d" % [ch, pi, sc]
