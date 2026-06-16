extends Control

@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton
var battle_scene = preload("res://scenes/battle/battle.tscn")

func _ready() -> void:
    start_button.pressed.connect(_on_start_button_pressed)
    quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed() -> void:
    print("Start button pressed")
    get_tree().change_scene_to_packed(battle_scene)

func _on_quit_button_pressed() -> void:
    print("Quit button pressed")
    get_tree().quit()