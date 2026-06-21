extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.mana_changed.connect(_on_mana_changed)
	text = str(GameState.mana)  # show correct value immediately on load

func _on_mana_changed(new_value: int) -> void:
	text = str(new_value)
