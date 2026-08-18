extends CanvasLayer
class_name UI

signal open_booking
signal open_menu

var time_label: Label
var money_label: Label
var day_label: Label
var status_label: Label
var menu_button: Button
var booking_button: Button
var concert_indicator: ColorRect

var time_system: TimeSystem
var game_state: GameState
var concert_manager: ConcertManager
var pub_manager: PubManager

var menu_open: bool = false
var booking_open: bool = false
var menu_panel: Control
var booking_panel: Control


func _ready() -> void:
	_create_ui()
	time_system = get_node_or_null("/root/Main/TimeSystem")
	game_state = get_node_or_null("/root/Main/GameState")
	concert_manager = get_node_or_null("/root/Main/ConcertManager")
	pub_manager = get_node_or_null("/root/Main/PubManager")
	if time_system:
		time_system.time_updated.connect(_update_time)
	if game_state:
		game_state.money_changed.connect(_update_money)
	_update_time(time_system.get_game_time() if time_system else null)
	_update_money(game_state.money if game_state else 0)


func _create_ui() -> void:
	var top_bar = PanelContainer.new()
	top_bar.position = Vector2(10, 10)
	top_bar.size = Vector2(460, 50)
	top_bar.pivot_offset = Vector2(0, 0)
	add_child(top_bar)

	var hbox = HBoxContainer.new()
	top_bar.add_child(hbox)

	day_label = Label.new()
	day_label.text = "Day 1"
	day_label.add_theme_color_override("font_color", Color("#5D4037"))
	day_label.add_theme_font_size_override("font_size", 18)
	hbox.add_child(day_label)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(20, 0)
	hbox.add_child(spacer)

	time_label = Label.new()
	time_label.text = "14:00"
	time_label.add_theme_color_override("font_color", Color("#5D4037"))
	time_label.add_theme_font_size_override("font_size", 18)
	hbox.add_child(time_label)

	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer2)

	money_label = Label.new()
	money_label.text = "₩ 500,000"
	money_label.add_theme_color_override("font_color", Color("#2E7D32"))
	money_label.add_theme_font_size_override("font_size", 18)
	hbox.add_child(money_label)

	var bottom_bar = PanelContainer.new()
	bottom_bar.position = Vector2(10, 660)
	bottom_bar.size = Vector2(460, 50)
	add_child(bottom_bar)

	var bottom_hbox = HBoxContainer.new()
	bottom_bar.add_child(bottom_hbox)

	menu_button = Button.new()
	menu_button.text = "Menu"
	menu_button.pressed.connect(_toggle_menu)
	bottom_hbox.add_child(menu_button)

	var spacer3 = Control.new()
	spacer3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_hbox.add_child(spacer3)

	status_label = Label.new()
	status_label.text = "OPEN"
	status_label.add_theme_color_override("font_color", Color("#2E7D32"))
	status_label.add_theme_font_size_override("font_size", 16)
	bottom_hbox.add_child(status_label)

	var spacer4 = Control.new()
	spacer4.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_hbox.add_child(spacer4)

	booking_button = Button.new()
	booking_button.text = "Book Band"
	booking_button.pressed.connect(_toggle_booking)
	bottom_hbox.add_child(booking_button)

	_create_menu_panel()
	_create_booking_panel()


func _create_menu_panel() -> void:
	menu_panel = PanelContainer.new()
	menu_panel.position = Vector2(10, 70)
	menu_panel.size = Vector2(200, 200)
	menu_panel.visible = false
	add_child(menu_panel)

	var vbox = VBoxContainer.new()
	menu_panel.add_child(vbox)

	var title = Label.new()
	title.text = "Menu"
	vbox.add_child(title)

	var save_btn = Button.new()
	save_btn.text = "Save Game"
	save_btn.pressed.connect(_on_save)
	vbox.add_child(save_btn)

	var reset_btn = Button.new()
	reset_btn.text = "New Game"
	reset_btn.pressed.connect(_on_reset)
	vbox.add_child(reset_btn)


func _create_booking_panel() -> void:
	booking_panel = PanelContainer.new()
	booking_panel.position = Vector2(270, 70)
	booking_panel.size = Vector2(200, 200)
	booking_panel.visible = false
	add_child(booking_panel)

	var vbox = VBoxContainer.new()
	booking_panel.add_child(vbox)

	var title = Label.new()
	title.text = "Book Band"
	vbox.add_child(title)


func _update_time(game_time: GameTime) -> void:
	if not game_time:
		return
	time_label.text = game_time.get_formatted_time()
	day_label.text = game_time.get_formatted_date()
	if time_system:
		if time_system.is_open():
			status_label.text = "OPEN"
			status_label.add_theme_color_override("font_color", Color("#2E7D32"))
		else:
			status_label.text = "CLOSED"
			status_label.add_theme_color_override("font_color", Color("#C62828"))


func _update_money(amount: int) -> void:
	money_label.text = "₩ %s" % str(amount).pad_zeros(8)


func _toggle_menu() -> void:
	menu_open = not menu_open
	menu_panel.visible = menu_open
	if booking_open:
		booking_open = false
		booking_panel.visible = false


func _toggle_booking() -> void:
	booking_open = not booking_open
	booking_panel.visible = booking_open
	if menu_open:
		menu_open = false
		menu_panel.visible = false


func _on_save() -> void:
	menu_open = false
	menu_panel.visible = false
	get_node("/root/Main")._save_game()


func _on_reset() -> void:
	menu_open = false
	menu_panel.visible = false
	get_node("/root/Main/GameState").reset()
	get_tree().reload_current_scene()
