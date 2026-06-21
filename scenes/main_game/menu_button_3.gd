extends Button

@onready var canvas_layer = $"../../../../.."
@onready var color_layer = $"../../../.."
@onready var hover_sound = $"../../../../../../hoversfx"
@onready var click_sound = $"../../../../../../clicksfx"



func _ready():
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	

func _on_pressed():
	click_sound.play()
	var tween = create_tween()
	tween.tween_property(color_layer, "color", Color(0, 0, 0, 0), 1)
	await tween.finished
	canvas_layer.visible = false


func _on_mouse_entered():
	hover_sound.play()
