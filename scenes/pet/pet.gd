class_name Pet
extends Resource

@export var pet_name: String = "Pet"
@export var species: String = "Creature" # ex: "Turtle", "Wolf"
@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export_enum("Available", "On Mission", "Dead") var status: String = "Available"

var is_on_mission: bool = false

func _init(name: String = "Pet", init_species: String = "Creature", init_max_health: float = 100.0) -> void:
	pet_name = name
	species = init_species
	max_health = init_max_health
	current_health = init_max_health

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
