extends Node
class_name MusicSystem

signal song_started(song: Song)
signal song_finished(song: Song)
signal playlist_updated
signal discovery_unlocked(song: Song)
signal streaming_progress(progress: float, song: Song)

@onready var player: AudioStreamPlayer = $AudioStreamPlayer
@onready var stream_player: AudioStreamPlayer = $StreamPlayer

var game_state: GameState
var time_system: TimeSystem
var band_manager: BandManager

var playlist: Array[Song] = []
var current_song: Song = null
var is_streaming: bool = false
var stream_queue: Array[Song] = []
var current_stream_index: int = -1
var playback_progress: float = 0.0
var last_tick: float = 0.0

var stream_mode: bool = false
var repeat_mode: bool = false
var shuffle_mode: bool = false

const BASE_STREAM_RPM = 1.0


func _ready() -> void:
	process_mode = Node.PROCESS_ALWAYS
	_refresh_playlist()
	time_system = get_node_or_null("/root/Main/TimeSystem")
	game_state = get_node_or_null("/root/Main/GameState")
	band_manager = get_node_or_null("/root/Main/BandManager")
	if time_system:
		time_system.day_changed.connect(_on_day_changed)


func _process(delta: float) -> void:
	if not is_streaming or not current_song:
		return
	playback_progress += delta
	if playback_progress >= current_song.duration_sec:
		_advance_stream()


func _on_day_changed(new_day: int) -> void:
	_refresh_playlist()
	playlist_updated.emit()


func _refresh_playlist() -> void:
	var unlocked = SongDatabase.get_unlocked_songs(game_state.day)
	playlist.clear()
	for s in unlocked:
		if s.id in game_state.discovered_songs:
			playlist.append(s)
	if current_song and not playlist.has(current_song):
		current_song = null
		is_streaming = false


func play_song(song: Song) -> void:
	if not song.unlocked:
		return
	current_song = song
	is_streaming = true
	playback_progress = 0.0
	stream_mode = false
	_apply_stream_audio(song)
	player.play()
	streaming_progress.emit(0.0, song)
	song_started.emit(song)


func stream_playlist() -> void:
	if playlist.is_empty():
		return
	is_streaming = true
	stream_mode = true
	playback_progress = 0.0
	_next_stream()
	stream_player.play()


func stop_playback() -> void:
	is_streaming = false
	stream_mode = false
	current_song = null
	player.stop()
	stream_player.stop()


func pause_playback() -> void:
	if stream_mode:
		stream_player.stream_paused = true
	else:
		player.stream_paused = true


func resume_playback() -> void:
	if stream_mode:
		stream_player.stream_paused = false
	else:
		player.stream_paused = false


func toggle_stream_mode(enabled: bool) -> void:
	stream_mode = enabled
	if enabled and not current_song:
		if not playlist.is_empty():
			stream_playlist()
	else:
		stream_player.stop()


func try_discover_from_concert(band: Band) -> void:
	var song = SongDatabase.discover_song(game_state.day, band.id)
	if song:
		game_state.discover_song(song)
		discovery_unlocked.emit(song)
		_refresh_playlist()
		playlist_updated.emit()


func get_current_song() -> Song:
	return current_song


func get_stream_progress() -> float:
	if not current_song or current_song.duration_sec <= 0:
		return 0.0
	return clamp(playback_progress / current_song.duration_sec, 0.0, 1.0)


func get_playlist() -> Array[Song]:
	return playlist


func _next_stream() -> void:
	if playlist.is_empty():
		is_streaming = false
		stream_player.stop()
		return
	current_stream_index += 1
	if current_stream_index >= playlist.size():
		if repeat_mode:
			current_stream_index = 0
		else:
			is_streaming = false
			stream_player.stop()
			current_song = null
			return
	current_song = playlist[current_stream_index]
	playback_progress = 0.0
	_apply_stream_audio(current_song)
	streaming_progress.emit(0.0, current_song)
	song_started.emit(current_song)


func _advance_stream() -> void:
	var finished = current_song
	if stream_mode:
		_next_stream()
	else:
		is_streaming = false
		current_song = null
		player.stop()
	song_finished.emit(finished)


func _apply_stream_audio(song: Song) -> void:
	var target = stream_player if stream_mode else player
	target.stop()
	# In a full build, load res://assets/audio/songs/<song.id>.ogg here.
	# For scaffolding, we keep the player ready and rely on UI/progress.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		if is_streaming:
			if player.playing or stream_player.playing:
				pause_playback()
			else:
				resume_playback()
		elif not playlist.is_empty():
			stream_playlist()
