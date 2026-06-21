class_name MissionSelection
extends Control

const MISSION_CARD_SCENE := preload("res://scenes/ui/mission_selection/mission_card/mission_card.tscn")

@onready var card_container: HBoxContainer = $HBoxContainer

func _ready() -> void:
	_build_mission_cards()
	Events.mission_selected.connect(_on_mission_selected)

func _build_mission_cards() -> void:
	for child in card_container.get_children():
		child.queue_free()
	for mission in GameState.available_missions:
		var card := MISSION_CARD_SCENE.instantiate() as MissionCard
		card_container.add_child(card)
		card.setup(mission)

func _on_mission_selected() -> void:
	hide()
