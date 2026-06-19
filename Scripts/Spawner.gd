extends Node
class_name Spawner

const ENEMY_SCENE = preload("res://scenes/enemy/enemy.tscn")

const WAVE_DATA: Array[Dictionary] = [
	{ "count": 4, "interval": 2.0},
	{ "count": 4, "interval": 1.5},
#	{ "count": 6, "interval": 2.0},
#	{ "count": 6, "interval": 1.2},
#	{ "count": 8, "interval": 2.0},
#	{ "count": 8, "interval": 1.2},
#	{ "count": 10, "interval": 2.0},
#	{ "count": 10, "interval": 1.2},
#	{ "count": 12, "interval": 2.5},
]
@onready var spawn_timer: Timer = $SpawnTimer

@onready var enemies_container: Node2D = get_parent().get_node("World/Enemies") as Node2D

var current_wave: int = 0
var enemies_remaining: int = 0
var wave_active: bool = false

signal wave_started(wave_number: int)
signal wave_cleared
signal all_waves_cleared

func _ready() -> void:
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

# call this from "next Wave" button in UI
func start_next_wave() -> void:
	if wave_active:
		return
	if current_wave >= WAVE_DATA.size():
		all_waves_cleared.emit()
		return
 
	var data = WAVE_DATA[current_wave]
	enemies_remaining = data["count"]
	spawn_timer.wait_time = data["interval"]
	wave_active = true
 
	wave_started.emit(current_wave + 1)
 
	# Spawn first enemy immediately, then timer handles the rest
	_spawn_enemy()
	enemies_remaining -= 1
 
	if enemies_remaining > 0:
		spawn_timer.start()
	else:
		_on_wave_spawning_done()

func _spawn_enemy() -> void:
	var enemy = ENEMY_SCENE.instantiate()
	enemies_container.add_child(enemy)

func _on_spawn_timer_timeout() -> void:
	_spawn_enemy()
	enemies_remaining -= 1
 
	if enemies_remaining <= 0:
		spawn_timer.stop()
		_on_wave_spawning_done()

func _on_wave_spawning_done() -> void:
	# All enemies for this wave have been spawned.
	# Wave is "cleared" once all spawned enemies are also dead.
	# Poll via a short timer until enemies_container is empty.
	_check_wave_cleared()

func _check_wave_cleared() -> void:
	if enemies_container.get_child_count() > 0:
		await get_tree().create_timer(0.5).timeout
		_check_wave_cleared()
	else:
		wave_active = false
		current_wave += 1
		wave_cleared.emit()
		if current_wave >= WAVE_DATA.size():
			all_waves_cleared.emit()
