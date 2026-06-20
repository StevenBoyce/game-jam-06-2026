extends Sprite2D

var speed = 10.0

func _process(delta):
	position.x += -speed * delta
