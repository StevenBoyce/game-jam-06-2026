class_name Overlay
extends Control

@onready var overlay3: Control = %Overlay3

func _ready() -> void:
	Events.overlay_icon_clicked.connect(_on_overlay_icon_clicked)

func _on_overlay_icon_clicked(view_name: String) -> void:
	if view_name == "pets":
		overlay3.visible = true
