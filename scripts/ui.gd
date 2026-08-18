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
var music_system: MusicSystem

var menu_open: bool = false
var booking_open: bool = false
var menu_panel: Control
var booking_panel: Control

var music_panel: PanelContainer
var song_title_label: Label
var artist_label: Label
var play_pause_button: Button
var stream_button: Button
var progress_bar: ProgressBar
var discovery_toast: PanelContainer
var discovery_label: Label
var discovery_timer: float = 0.0


func _ready() -> void:
	_create_ui()
	time_system = get_node_or_null("/root/Main/TimeSystem")
	game_state = get_node_or_null("/root/Main/GameState")
	concert_manager = get_node_or_null("/root/Main/ConcertManager")
	pub_manager = get_node_or_null("/root/Main/PubManager")
	music_system = get_node_or_null("/root/Main/MusicSystem")
	if time_system:
		time_system.time_updated.connect(_update_time)
	if game_state:
		game_state.money_changed.connect(_update_money)
	if music_system:
		music_system.song_started.connect(_on_song_started)
		music_system.song_finished.connect(_on_song_finished)
		music_system.playlist_updated.connect(_update_music_ui)
		music_system.discovery_unlocked.connect(_on_song_discovered)
		music_system.streaming_progress.connect(_on_stream_progress)
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
	_create_music_panel()
	_create_discovery_toast()


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


func _create_music_panel() -> void:
	music_panel = PanelContainer.new()
	music_panel.position = Vector2(10, 610)
	music_panel.size = Vector2(460, 40)
	music_panel.visible = false
	add_child(music_panel)

	var hbox = HBoxContainer.new()
	music_panel.add_child(hbox)

	song_title_label = Label.new()
	song_title_label.text = "No song"
	song_title_label.add_theme_color_override("font_color", Color("#3E2723"))
	song_title_label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(song_title_label)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(10, 0)
	hbox.add_child(spacer)

	artist_label = Label.new()
	artist_label.text = ""
	artist_label.add_theme_color_override("font_color", Color("#5D4037"))
	artist_label.add_theme_font_size_override("font_size", 12)
	hbox.add_child(artist_label)

	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer2)

	play_pause_button = Button.new()
	play_pause_button.text = "Play"
	play_pause_button.pressed.connect(_toggle_play_pause)
	hbox.add_child(play_pause_button)

	stream_button = Button.new()
	stream_button.text = "Stream"
	stream_button.pressed.connect(_toggle_stream)
	hbox.add_child(stream_button)

	progress_bar = ProgressBar.new()
	progress_bar.size = Vector2(80, 10)
	progress_bar.max_value = 1.0
	progress_bar.value = 0.0
	progress_bar.show_percentage = false
	hbox.add_child(progress_bar)


func _create_discovery_toast() -> void:
	discovery_toast = PanelContainer.new()
	discovery_toast.position = Vector2(60, 200)
	discovery_toast.size = Vector2(360, 60)
	discovery_toast.visible = false
	add_child(discovery_toast)

	var vbox = VBoxContainer.new()
	discovery_toast.add_child(vbox)

	var title = Label.new()
	title.text = "New Song Discovered!"
	title.add_theme_color_override("font_color", Color("#FFD700"))
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	discovery_label = Label.new()
	discovery_label.text = ""
	discovery_label.add_theme_color_override("font_color", Color("#FFFFFF"))
	discovery_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(discovery_label)


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


func _toggle_play_pause() -> void:
	if not music_system:
		return
	if music_system.is_streaming:
		if music_system.player.playing or music_system.stream_player.playing:
			music_system.pause_playback()
			play_pause_button.text = "Play"
		else:
			music_system.resume_playback()
			play_pause_button.text = "Pause"
	elif not music_system.playlist.is_empty():
		music_system.stream_playlist()
		play_pause_button.text = "Pause"
		music_panel.visible = true


func _toggle_stream() -> void:
	if not music_system:
		return
	if music_system.stream_mode:
		music_system.toggle_stream_mode(false)
		stream_button.text = "Stream"
		play_pause_button.text = "Play"
	else:
		music_system.toggle_stream_mode(true)
		stream_button.text = "Stop"
		play_pause_button.text = "Pause"
		music_panel.visible = true


func _on_song_started(song: Song) -> void:
	song_title_label.text = song.title
	artist_label.text = song.artist
	progress_bar.value = 0.0
	music_panel.visible = true


func _on_song_finished(song: Song) -> void:
	progress_bar.value = 1.0
	play_pause_button.text = "Play"


func _on_stream_progress(progress: float, song: Song) -> void:
	progress_bar.value = progress


func _on_song_discovered(song: Song) -> void:
	discovery_label.text = "%s - %s" % [song.title, song.artist]
	discovery_toast.visible = true
	discovery_timer = 4.0


func _update_music_ui() -> void:
	if music_system and music_system.current_song:
		song_title_label.text = music_system.current_song.title
		artist_label.text = music_system.current_song.artist
		music_panel.visible = true


func _process(delta: float) -> void:
	if discovery_timer > 0.0:
		discovery_timer -= delta
		if discovery_timer <= 0.0:
			discovery_toast.visible = false
	if music_system and music_system.current_song and music_system.is_streaming:
		progress_bar.value = music_system.get_stream_progress()


func _on_save() -> void:
	menu_open = false
	menu_panel.visible = false
	get_node("/root/Main")._save_game()


func _on_reset() -> void:
	menu_open = false
	menu_panel.visible = false
	get_node("/root/Main/GameState").reset()
	get_tree().reload_current_scene()
