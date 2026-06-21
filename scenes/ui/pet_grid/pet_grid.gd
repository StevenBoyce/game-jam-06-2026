class_name PetGrid
extends GridContainer

var default_labels: Array[String] = ['Name', 'HP', 'Status']

func _ready() -> void:
	Events.pets_changed.connect(on_pets_changed)

func add_label(text: String):
	var label = Label.new()
	label.text = text
	add_child(label)

func on_pets_changed() -> void:
	for child in get_children():
		child.queue_free()
	for label in default_labels:
		add_label(label)
	for pet in GameState.pets:
		add_label(pet.pet_name)
		add_label("{current_health}/{max_health}".format({"current_health": pet.current_health, "max_health": pet.max_health}))
		add_label(pet.status)
