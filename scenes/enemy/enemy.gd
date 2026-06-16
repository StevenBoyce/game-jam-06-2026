extends Combatant

class_name Enemy

@export var attack_range: float = 20.0

@onready var aggro_zone: Area2D = $AggroZone
@onready var attack_hitbox: Area2D = $AttackHitbox

var pets_in_range: Array[Node2D] = []

func _ready() -> void:
	super._ready()
	add_to_group("enemies")
 
	# Set the default target to the tree
	current_target = get_tree().get_first_node_in_group("tree")
 
	aggro_zone.body_entered.connect(_on_aggro_zone_body_entered)
	aggro_zone.body_exited.connect(_on_aggro_zone_body_exited)
 
 
func _process(delta: float) -> void:
	if current_target == null or not is_instance_valid(current_target):
		_retarget()
		return
 
	var distance = global_position.distance_to(current_target.global_position)
	if distance > attack_range:
		move_toward_target(delta)
	else:
		try_attack(current_target)
 
 
func _on_aggro_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("pets"):
		pets_in_range.append(body)
		# A pet engaging always takes priority over the tree
		current_target = body
 
 
func _on_aggro_zone_body_exited(body: Node2D) -> void:
	if body in pets_in_range:
		pets_in_range.erase(body)
	if current_target == body:
		_retarget()
 
 
func _retarget() -> void:
	# Prefer another pet still in range, otherwise retarget the tree
	pets_in_range = pets_in_range.filter(func(p): return is_instance_valid(p))
	if pets_in_range.size() > 0:
		current_target = pets_in_range[0]
	else:
		current_target = get_tree().get_first_node_in_group("tree")
