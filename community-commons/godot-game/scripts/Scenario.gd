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
