class_name Main
extends Node2D

@export var start_scene: PackedScene = preload("res://scenes/main_game/main_game.tscn")
@onready var fade: Fade = $Fade
var current_scene: Node

func _ready() -> void:
	current_scene = start_scene.instantiate()
	add_child(current_scene)
	Events._change_scene.connect(_on_change_scene)

func _on_change_scene(scene: PackedScene) -> void:
	await fade.fade_out(1).finished
	current_scene.queue_free()
	current_scene = scene.instantiate()
	add_child(current_scene)
	await fade.fade_in(1).finished
