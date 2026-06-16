extends CharacterBody2D

class_name Combatant

@export var max_health: float = 10.0
@export var attack_damage: float = 1.0
@export var attack_cooldown: float = 1.0
@export var move_speed: float = 50.0

var health: float
var current_target: Node2D = null
var can_attack: bool = true

signal died
signal health_changed(new_health: float, max_health:float)

@onready var attack_timer: Timer = $AttackTimer

func _ready() -> void:
	health = max_health
	attack_timer.wait_time = attack_cooldown
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	
func take_damage(amount: float) -> void:
	health -= amount
	health_changed.emit(health, max_health)
	if health <= 0:
		die()

func die() -> void:
	died.emit()
	queue_free()
 
func _on_attack_timer_timeout() -> void:
	can_attack = true
 
func try_attack(target: Node2D) -> void:
	if can_attack and target != null and is_instance_valid(target):
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)
		can_attack = false
		attack_timer.start()
 
func move_toward_target(delta: float) -> void:
	if current_target == null or not is_instance_valid(current_target):
		return
	var direction = (current_target.global_position - global_position).normalized()
	position += direction * move_speed * delta
