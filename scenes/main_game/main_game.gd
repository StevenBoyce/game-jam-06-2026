class_name MainGame
extends Node2D

@onready var mana_label: Label = %ManaLabel
@onready var overlay: Control = %Overlay
@onready var pet_grid_scene: PackedScene = preload("res://scenes/ui/pet_grid/pet_grid.tscn")


signal mana_changed(new_mana: int)
signal mutation_unlocked()
signal mutation_grafted()
signal mission_started()
signal mission_completed()

# - Tree stats -
var mana: int = 0
var max_mana: int = 100
var pet_capacity: int = 3
var pet_acquisition_rate: float = 1.0
var pet_healing_rate: float = 1.0
var mana_reward_multiplier: float = 1.0
var success_buff_active: bool = false


# - Collections -
var pets: Array[Pet] = []
var unlocked_mutations: Array[TreeMutation] = []
var available_missions: Array[MutationMission] = []
var mutation_history: Array[TreeMutation] = []
var active_mutation: TreeMutation = null

enum Faction { ELDRITCH, NECROMANCER }
enum MissionKind { EGG, MUSHROOM }

const MISSION_COUNT := 3
const MISSION_REFRESH_SECONDS := 300.0
const BORDER_TIERS := ["bronze", "silver", "gold", "purple"]
const BORDER_WEIGHTS := [40, 30, 20, 10]
const FACTION_NAMES := {
	Faction.ELDRITCH: "eldritch",
	Faction.NECROMANCER: "necromancer",
}
const TIER_PET_RARITY_REWARDS := {
	"bronze": 10.0,
	"silver": 15.0,
	"gold": 20.0,
	"purple": 25.0,
}
const TIER_GAIN_MANA_REWARDS := {
	"bronze": 25.0,
	"silver": 40.0,
	"gold": 55.0,
	"purple": 75.0,
}

var _mission_refresh_timer: Timer

func _ready() -> void:
	if is_instance_valid(mana_label):
		mana_label.text = str(mana)
	if is_instance_valid(overlay):
		overlay.visible = false
	Events.overlay_closed.connect(_on_overlay_closed)

	Events.overlay_icon_clicked.connect(_on_overlay_icon_clicked)
	
	add_pet(Pet.new("Steve", "Turtle", 100.0))
	add_pet(Pet.new("Karen", "Wolf", 100.0))
	Events.pets_changed.emit()

	_setup_mission_refresh()

func _on_overlay_icon_clicked(view_name: String) -> void:
	print("overlay icon clicked: ", view_name)
	print("overlay is valid: ", is_instance_valid(overlay))
	if is_instance_valid(overlay):
		overlay.visible = true

func _on_overlay_closed() -> void:
	print("overlay closed")
	print("overlay is valid: ", is_instance_valid(overlay))
	if is_instance_valid(overlay):
		overlay.visible = false

func init_missions() -> void:
	available_missions.clear()
	var used_titles: Dictionary = {}
	var attempts := 0
	const MAX_ATTEMPTS := 100
	var kinds := [MissionKind.EGG, MissionKind.MUSHROOM]
	var factions := [Faction.ELDRITCH, Faction.NECROMANCER]
	while available_missions.size() < MISSION_COUNT and attempts < MAX_ATTEMPTS:
		attempts += 1
		var kind: MissionKind = kinds[randi() % kinds.size()]
		var faction: Faction = factions[randi() % factions.size()]
		var title := _build_mission_title(kind, faction)
		if used_titles.has(title):
			continue
		used_titles[title] = true
		available_missions.append(_create_mission(kind, faction))
	if available_missions.size() < MISSION_COUNT:
		push_warning("Could only generate %d unique missions." % available_missions.size())
	print(available_missions)

func _setup_mission_refresh() -> void:
	init_missions()
	_mission_refresh_timer = Timer.new()
	_mission_refresh_timer.wait_time = MISSION_REFRESH_SECONDS
	_mission_refresh_timer.autostart = true
	_mission_refresh_timer.timeout.connect(init_missions)
	add_child(_mission_refresh_timer)

func _pick_weighted_border_tier() -> String:
	var total := 0
	for weight in BORDER_WEIGHTS:
		total += weight
	var roll := randi_range(1, total)
	var cumulative := 0
	for i in BORDER_TIERS.size():
		cumulative += BORDER_WEIGHTS[i]
		if roll <= cumulative:
			return BORDER_TIERS[i]
	return BORDER_TIERS[0]

func _border_path(faction: Faction, tier: String) -> String:
	match faction:
		Faction.ELDRITCH:
			return "res://assets/cards/eldritch_%s.png" % tier
		Faction.NECROMANCER:
			return "res://assets/cards/Necromancer_%s.png" % tier
	return ""

func _item_path(kind: MissionKind, faction: Faction) -> String:
	if kind == MissionKind.EGG:
		return "res://assets/cards/items/egg.png"
	match faction:
		Faction.ELDRITCH:
			return "res://assets/cards/items/eldritch_shroom.png"
		Faction.NECROMANCER:
			return "res://assets/cards/items/necro_shroom.png"
	return ""

func _build_mission_title(kind: MissionKind, faction: Faction) -> String:
	var faction_name: String = FACTION_NAMES[faction]
	match kind:
		MissionKind.EGG:
			var article := "an" if faction == Faction.ELDRITCH else "a"
			return "Get %s %s egg" % [article, faction_name]
		MissionKind.MUSHROOM:
			return "Forage for some %s mushrooms" % faction_name
	return ""

func _create_mission(kind: MissionKind, faction: Faction) -> MutationMission:
	var tier := _pick_weighted_border_tier()
	var mission := MutationMission.new()
	mission.title = _build_mission_title(kind, faction)
	mission.card_border = load(_border_path(faction, tier))
	mission.item_image = load(_item_path(kind, faction))
	mission.pets_required = 1
	mission.success_rate = 50
	mission.mana_reward = 50
	mission.duration = 20.0
	if kind == MissionKind.EGG:
		mission.reward_type = MutationMission.RewardType.PET_RARITY_CHANCE
		mission.reward_value = TIER_PET_RARITY_REWARDS[tier]
	else:
		mission.reward_type = MutationMission.RewardType.GAIN_MANA
		mission.reward_value = TIER_GAIN_MANA_REWARDS[tier]
	return mission

func _process(delta: float) -> void:
	var changed := false
	for pet in pets:
		if not pet.is_on_mission and pet.current_health < pet.max_health:
			pet.heal(pet_healing_rate * delta)
			changed = true
	if changed:
		Events.pets_changed.emit()

func add_mana(amount: int) -> void:
	mana = min(mana + amount, max_mana)
	mana_changed.emit(mana)

func spend_mana(amount: int) -> bool:
	if mana < amount:
		return false
	mana -= amount
	mana_changed.emit(mana)
	return true

func add_pet(pet: Pet) -> bool:
	if pets.size() >= pet_capacity:
		return false
	pets.append(pet)
	Events.pets_changed.emit()
	return true

func generate_random_pet() -> Pet:
	var species_pool := ["Turtle"]
	var p := Pet.new()
	p.species = species_pool[randi() % species_pool.size()]
	p.pet_name = p.species
	p.max_health = 100.0
	p.current_health = 100.0
	return p

func start_mission(mission: MutationMission, selected_pets: Array[Pet]) -> Dictionary:
	if selected_pets.size() != mission.pets_required:
		push_warning("MutationMission '%s' needs %d pets, got %d." % [
			mission.title, mission.pets_required, selected_pets.size()
		])
		return {}

	for pet in selected_pets:
		if not pets.has(pet) or not pet.is_alive():
			push_warning("Invalid or dead pet selected for mission.")
			return {}

	mission_started.emit(mission)

	for pet in selected_pets:
		pet.is_on_mission = true

	var effective_rate := mission.get_effective_success_rate(success_buff_active)
	if success_buff_active:
		success_buff_active = false

	var roll := randi_range(1, 100)
	var success := roll <= effective_rate

	for pet in selected_pets:
		var loss := mission.get_random_health_loss()
		pet.take_damage(loss)
		pet.is_on_mission = false

	Events.pets_changed.emit()
	
	var result := _resolve_mission(mission, success)
	mission_completed.emit(mission, success)
	return result


func _resolve_mission(mission: MutationMission, success: bool) -> Dictionary:
	var result := {"success": success, "mana_awarded": 0, "unlocked": null, "bonus_pet": false}
	if not success:
		return result

	var reward_amount := mission.mana_reward
	if mana_reward_multiplier != 1.0:
		reward_amount = int(round(reward_amount * mana_reward_multiplier))
	add_mana(reward_amount)
	result["mana_awarded"] = reward_amount

	if mission.unlocks_mutation and not unlocked_mutations.has(mission.unlocks_mutation):
		unlocked_mutations.append(mission.unlocks_mutation)
		mutation_unlocked.emit(mission.unlocks_mutation)
		result["unlocked"] = mission.unlocks_mutation

	result["bonus_pet"] = _apply_mission_reward(mission)
	return result

func _apply_mission_reward(mission: MutationMission) -> bool:
	var bonus_pet_gained := false
	match mission.reward_type:
		# MutationMission.RewardType.PET_HEALTH_PERCENT:
		# 	for pet in pets:
		# 		pet.max_health *= (1.0 + mission.reward_value / 100.0)
		# 	Events.pets_changed.emit()
		# MutationMission.RewardType.SUCCESS_RATE_BUFF:
		# 	success_buff_active = true
		# MutationMission.RewardType.PET_ACQUISITION_RATE:
		# 	pet_acquisition_rate += mission.reward_value
		# MutationMission.RewardType.MAX_MANA:
		# 	max_mana += int(mission.reward_value)
		# MutationMission.RewardType.PET_HEALING_RATE:
		# 	pet_healing_rate += mission.reward_value
		# MutationMission.RewardType.MANA_REWARD_PERCENT:
		# 	mana_reward_multiplier += mission.reward_value / 100.0
		# MutationMission.RewardType.BONUS_PET_CHANCE:
		# 	if randf() * 100.0 < mission.reward_value:
		# 		bonus_pet_gained = add_pet(generate_random_pet())
		MutationMission.RewardType.PET_RARITY_CHANCE:
			if randf() * 100.0 < mission.reward_value:
				bonus_pet_gained = add_pet(generate_random_pet())
		MutationMission.RewardType.GAIN_MANA:
			add_mana(int(mission.reward_value))
	return bonus_pet_gained

# call this when purchasing mutations with mana
func graft_mutation(mutation: TreeMutation) -> bool:
	if not unlocked_mutations.has(mutation):
		push_warning("Mutation '%s' is not unlocked yet." % mutation.title)
		return false
	if not spend_mana(mutation.mana_cost):
		return false
	active_mutation = mutation
	mutation_history.append(mutation)
	mutation_grafted.emit(mutation)
	return true
