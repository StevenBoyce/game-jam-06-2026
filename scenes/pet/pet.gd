class_name Pet
extends Resource

@export var pet_name: String = "Pet"
@export var species: String = "Creature" # ex: "Turtle", "Wolf"
@export var max_health: float = 100.0
@export var current_health: float = 100.0

var is_on_mission: bool = false

func is_alive() -> bool:
	return current_health > 0.0

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)

func take_damage(amount: float) -> void:
	current_health = max(current_health - amount, 0.0)

func health_percent() -> float:
	if max_health <= 0.0:
		return 0.0
	return current_health / max_health
