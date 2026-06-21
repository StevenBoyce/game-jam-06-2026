
extends Sprite2D

@export var max_angle_degrees := 35.0
@export var min_angle_degrees := 2.0
@export var start_speed := 4.0
@export var speed_increase := 10.0
@export var decay_rate := 1.8

var time := 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	centered = true
	offset = Vector2(0, -texture.get_height() / 2.0)

func _process(delta: float) -> void:
	time += delta

	var angle_size := max_angle_degrees * exp(-decay_rate * time)
	var speed := start_speed + speed_increase * time

	rotation_degrees = sin(time * speed) * angle_size

	# Reset once the swing gets tiny
	if angle_size <= min_angle_degrees:
		time = 0.0
