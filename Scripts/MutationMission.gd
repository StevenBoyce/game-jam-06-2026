class_name MutationMission
extends Resource

enum RewardType {
	PET_HEALTH_PERCENT,    # increase pet max health by reward_value%
	SUCCESS_RATE_BUFF,     # grants the one-time mission success buff
	PET_ACQUISITION_RATE,  # increase pet acquisition rate by reward_value
	MAX_MANA,              # increase max mana by reward_value
	PET_HEALING_RATE,      # increase passive pet healing rate by reward_value
	MANA_REWARD_PERCENT,   # increase mana rewards by reward_value%
	BONUS_PET_CHANCE,      # reward_value% chance to bring home a new pet
}

@export var title: String = ""
@export_multiline var mutation_description: String = ""
@export var pets_required: int = 1
@export var health_loss_min: float = 10.0
@export var health_loss_max: float = 20.0
@export var mana_reward: int = 50
@export_enum("25", "50", "75", "100") var success_rate: int = 50
@export var reward_type: RewardType = RewardType.MAX_MANA
@export var reward_value: float = 0.0
@export var unlocks_mutation: TreeMutation = null

func get_random_health_loss() -> float:
	return randf_range(health_loss_min, health_loss_max)

func get_effective_success_rate(buff_active: bool) -> int:
	if not buff_active:
		return success_rate
	match success_rate:
		25:
			return 50
		50:
			return 75
		75, 100:
			return 100
		_:
			return success_rate
