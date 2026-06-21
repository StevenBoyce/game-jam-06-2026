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
	null
