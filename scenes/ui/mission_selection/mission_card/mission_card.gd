class_name MissionCard
extends PanelContainer

@onready var item_image: TextureRect = %ItemImage
@onready var title_label: Label = %TitleLabel

var mission: MutationMission

func setup(m: MutationMission) -> void:
	mission = m
	if is_instance_valid(m.card_border):
		var style := StyleBoxTexture.new()
		style.texture = m.card_border
		add_theme_stylebox_override("panel", style)
	item_image.texture = m.item_image
	title_label.text = m.title
	mission.mana_reward = randi_range(mission.mana_reward_min, mission.mana_reward_max)
