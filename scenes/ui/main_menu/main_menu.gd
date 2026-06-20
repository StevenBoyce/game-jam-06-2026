extends Control

@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton
var main_game_scene = preload("res://scenes/game.tscn")

func _ready() -> void:
    start_button.pressed.connect(_on_start_button_pressed)
    quit_button.pressed.connect(_on_quit_button_pressed)
    Events._change_scene.connect(_on_start_button_pressed)

func _on_start_button_pressed() -> void:
    print("Start button pressed")
    Events._change_scene.emit(main_game_scene)
    # get_tree().change_scene_to_packed(main_game_scene)

func _on_quit_button_pressed() -> void:
    get_tree().quit()