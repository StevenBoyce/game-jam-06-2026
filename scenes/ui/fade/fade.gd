class_name Fade
extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.color.a = 0.0


func fade(target_alpha: float, duration: float = 1):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", target_alpha, duration)
	return tween

func fade_in(duration: float = 1):
	return fade(0, duration)

func fade_out(duration: float = 1):
	return fade(1, duration)
