extends Node2D
class_name PlayerTree

@export var max_health: float = 100.0
 
var health: float
 
signal died
signal health_changed(new_health: float, max_health: float)
 
 
func _ready() -> void:
	health = max_health
	add_to_group("tree")
 
 
func take_damage(amount: float) -> void:
	health -= amount
	health_changed.emit(health, max_health)
	if health <= 0:
		die()
 
 
func die() -> void:
	died.emit()
	# game over logic here
 
