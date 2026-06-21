class_name ClickableIcon
extends TextureRect

@export var default_texture: Texture2D
@export var hovered_texture: Texture2D
@export var view_name: String
@onready var hover_sound = $"../../../../hoversfx"
@onready var click_sound = $"../../../../clicksfx"

func _ready() -> void:
	texture = default_texture
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func _on_mouse_entered() -> void:
	print("mouse entered")
	if is_instance_valid(hovered_texture):
		self.texture = hovered_texture
		hover_sound.play()
		

func _on_mouse_exited() -> void:
	print("mouse exited")
	if is_instance_valid(default_texture):
		self.texture = default_texture

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Events.overlay_icon_clicked.emit(view_name)
		click_sound.play()
