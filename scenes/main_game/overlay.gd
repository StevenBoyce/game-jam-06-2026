class_name Overlay
extends Control

@onready var mission_selection: MissionSelection = %MissionSelection
@onready var pet_grid: PetGrid = %PetGrid
@onready var close_button: Label = %CloseButton

func _ready() -> void:
	if is_instance_valid(mission_selection):
		mission_selection.visible = false
	if is_instance_valid(pet_grid):
		pet_grid.visible = false
	Events.overlay_icon_clicked.connect(_on_overlay_icon_clicked)
	close_button.gui_input.connect(_on_close_button_gui_input)

func _on_overlay_icon_clicked(view_name: String) -> void:
	if view_name == "missions":
		mission_selection.visible = true
	elif view_name == "pets":
		pet_grid.visible = true
	# elif view_name == "menu": TODO: Add menu


func _on_close_button_gui_input(event: InputEvent) -> void:
	print("close button clicked")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pet_grid.visible = false
		mission_selection.visible = false
		Events.overlay_closed.emit()
