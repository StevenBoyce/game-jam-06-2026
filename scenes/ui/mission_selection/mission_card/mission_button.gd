extends Button
signal mission_button_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	print("Mission Button ready, signal connected")

func _on_pressed() -> void:
	GameState.mana += owner.mission.mana_reward
	mission_button_pressed.emit()
	Events.mission_selected.emit()
	print("Mission Button Pressed")
