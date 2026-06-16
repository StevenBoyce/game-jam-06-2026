extends Combatant
class_name Pet
 
@export var attack_range: float = 20.0
 
@onready var aggro_zone: Area2D = $AggroZone
@onready var attack_hitbox: Area2D = $AttackHitbox
 
var enemies_in_range: Array[Node2D] = []

func _ready() -> void:
	super._ready()
	add_to_group("pets")
 
	aggro_zone.body_entered.connect(_on_aggro_zone_body_entered)
	aggro_zone.body_exited.connect(_on_aggro_zone_body_exited)
 
 
func _process(delta: float) -> void:
	if current_target == null or not is_instance_valid(current_target):
		_retarget()
		if current_target == null:
			return  # nothing to do, idle
 
	var distance = global_position.distance_to(current_target.global_position)
	if distance > attack_range:
		move_toward_target(delta)
	else:
		try_attack(current_target)
 
 
func _on_aggro_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		enemies_in_range.append(body)
		if current_target == null:
			current_target = body
 
 
func _on_aggro_zone_body_exited(body: Node2D) -> void:
	if body in enemies_in_range:
		enemies_in_range.erase(body)
	if current_target == body:
		_retarget()
 
 
func _retarget() -> void:
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	if enemies_in_range.size() > 0:
		current_target = enemies_in_range[0]
	else:
		current_target = null
