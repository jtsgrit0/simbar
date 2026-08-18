extends Node2D
class_name Customer

var customer_id: int
var drink: Drink
var max_patience: float
var current_patience: float
var state: String = "waiting"
var is_selected: bool = false

var sprite: ColorRect
var patience_bar: ProgressBar
var drink_icon: ColorRect

signal clicked(customer: Customer)
signal served(customer: Customer)


func _ready() -> void:
	z_index = 10
	_create_visuals()


func _create_visuals() -> void:
	sprite = ColorRect.new()
	sprite.size = Vector2(40, 56)
	sprite.color = Color("#E6C8A0")
	sprite.position = Vector2(-20, -56)
	add_child(sprite)

	var head = ColorRect.new()
	head.size = Vector2(32, 28)
	head.color = Color("#FFDAB9")
	head.position = Vector2(-16, -84)
	add_child(head)

	drink_icon = ColorRect.new()
	drink_icon.size = Vector2(10, 14)
	drink_icon.color = drink.icon_color
	drink_icon.position = Vector2(-5, -56)
	add_child(drink_icon)

	patience_bar = ProgressBar.new()
	patience_bar.size = Vector2(40, 6)
	patience_bar.position = Vector2(-20, -8)
	patience_bar.max_value = max_patience
	patience_bar.value = current_patience
	patience_bar.show_percentage = false
	add_child(patience_bar)


func _process(delta: float) -> void:
	if state == "waiting":
		current_patience -= delta
		patience_bar.value = current_patience
		if current_patience <= 0:
			state = "left"
			queue_free()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)


func select() -> void:
	is_selected = true
	var outline = ColorRect.new()
	outline.size = Vector2(44, 60)
	outline.color = Color("#FFD700")
	outline.position = Vector2(-22, -62)
	outline.name = "outline"
	add_child(outline)


func deselect() -> void:
	is_selected = false
	var outline = get_node_or_null("outline")
	if outline:
		outline.queue_free()


func serve() -> void:
	if state != "waiting":
		return
	state = "served"
	served.emit(self)
	queue_free()


func get_patience_ratio() -> float:
	return current_patience / max_patience
