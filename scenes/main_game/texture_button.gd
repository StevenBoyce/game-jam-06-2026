extends TextureButton

@export var max_angle_degrees = 35.0
@export var min_angle_degrees = 2.0
@export var start_speed = 4.0
@export var speed_increase = 10.0
@export var decay_rate = 1.8
@onready var overlay = %Turtle
@onready var egg =$"."
var time = 0.0

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	if texture_normal:
		pivot_offset = Vector2(
			texture_normal.get_width() / 2.0,
			texture_normal.get_height()
		)

func _process(delta: float) -> void:
	time += delta

	var angle_size = max_angle_degrees * exp(-decay_rate * time)
	var speed = start_speed + speed_increase * time

	rotation_degrees = sin(time * speed) * angle_size

	if angle_size <= min_angle_degrees:
		time = 0.0

func _on_pressed():
	overlay.visible = true	
	egg.visible = false

func _on_mouse_entered():
	null
