extends Node2D

@onready var player_tree: Node2D = %PlayerTree
@onready var spawn_point_1: Marker2D = %SpawnPoint1
@onready var spawn_timer: Timer = %SpawnTimer

func _ready() -> void:
	handle_spawn(spawn_point_1, preload("res://scenes/enemy/enemy.tscn"))
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func handle_spawn(spawn_point: Marker2D, type: PackedScene) -> void:
	var combatant = type.instantiate()
	combatant.global_position = spawn_point.global_position
	add_child(combatant)

func _on_spawn_timer_timeout() -> void:
	handle_spawn(spawn_point_1, preload("res://scenes/enemy/enemy.tscn"))
	spawn_timer.start()
