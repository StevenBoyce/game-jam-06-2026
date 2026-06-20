extends Node

signal mana_changed(new_mana: int)
signal mutation_unlocked()
signal mutation_grafted()
signal pets_changed
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

func _process(delta: float) -> void:
	var changed := false
	for pet in pets:
		if not pet.is_on_mission and pet.current_health < pet.max_health:
			pet.heal(pet_healing_rate * delta)
			changed = true
	if changed:
		pets_changed.emit()

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
	pets_changed.emit()
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

	pets_changed.emit()
	
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
		MutationMission.RewardType.PET_HEALTH_PERCENT:
			for pet in pets:
				pet.max_health *= (1.0 + mission.reward_value / 100.0)
			pets_changed.emit()
		MutationMission.RewardType.SUCCESS_RATE_BUFF:
			success_buff_active = true
		MutationMission.RewardType.PET_ACQUISITION_RATE:
			pet_acquisition_rate += mission.reward_value
		MutationMission.RewardType.MAX_MANA:
			max_mana += int(mission.reward_value)
		MutationMission.RewardType.PET_HEALING_RATE:
			pet_healing_rate += mission.reward_value
		MutationMission.RewardType.MANA_REWARD_PERCENT:
			mana_reward_multiplier += mission.reward_value / 100.0
		MutationMission.RewardType.BONUS_PET_CHANCE:
			if randf() * 100.0 < mission.reward_value:
				bonus_pet_gained = add_pet(generate_random_pet())
	return bonus_pet_gained

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
