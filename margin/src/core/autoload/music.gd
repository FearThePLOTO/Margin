extends Node
## Music player (autoload "Music"). Keeps playing across scene swaps.
##
## A playlist is every track in MUSIC_DIR named "<playlist>_<n>.ogg":
##   ui_music_1.ogg, ui_music_2.ogg            -> Music.play(&"ui_music")
##   lava_and_cave_1.ogg ... lava_and_cave_4   -> Music.play(&"lava_and_cave")
## Drop a new "<playlist>_5.ogg" in the folder and it joins that playlist.
##
## When a track ends, a random OTHER track of the same playlist starts (never
## the same one twice in a row). Switching playlists crossfades. Calling
## play() with the playlist that is already playing does nothing, so the menu
## music keeps going between the menu and the results screen.
## Plays on the "Music" bus (volume set in OPTIONS) and keeps going while paused.

const MUSIC_DIR := "res://src/features/audio/music/"
const FADE_S := 1.2
const SILENT_DB := -40.0
const DUCK_DB := -8.0

var current := &""
var _playlists := {}        # StringName -> Array[AudioStream]
var _players: Array[AudioStreamPlayer] = []
var _active := 0             # index into _players of the playing one
var _last_track: AudioStream
var _fade: Tween
var _ducked := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 2:
		var p := AudioStreamPlayer.new()
		p.bus = &"Music"
		p.volume_db = SILENT_DB
		p.finished.connect(_on_finished.bind(p))
		add_child(p)
		_players.append(p)
	_scan()


## Start a playlist (crossfades from whatever is playing). &"" = fade out.
func play(playlist: StringName) -> void:
	if playlist == current:
		return
	current = playlist
	if playlist == &"" or not _playlists.has(playlist):
		if playlist != &"":
			push_warning("Music: no tracks named %s_<n>.ogg in %s" % [playlist, MUSIC_DIR])
		_crossfade(null)
		return
	_crossfade(_pick())


func stop() -> void:
	play(&"")


## Pause screen: music drops a little while the game is frozen.
func set_ducked(on: bool) -> void:
	_ducked = on
	if _fade and _fade.is_running():
		return
	var p := _players[_active]
	if p.playing:
		create_tween().tween_property(p, "volume_db", _target_db(), 0.25)


func _target_db() -> float:
	return DUCK_DB if _ducked else 0.0


## Random track from the current playlist, not the one that just played.
func _pick() -> AudioStream:
	var tracks: Array = _playlists[current]
	var options := tracks.filter(func(t: AudioStream) -> bool: return t != _last_track)
	if options.is_empty():
		options = tracks
	_last_track = options.pick_random()
	return _last_track


func _crossfade(next: AudioStream) -> void:
	if _fade and _fade.is_running():
		_fade.kill()
		_players[1 - _active].stop()   # the one that was already fading out
	var old := _players[_active]
	var fade_old := old.playing
	if not fade_old and next == null:
		return
	_fade = create_tween().set_parallel(true)
	if fade_old:
		_fade.tween_property(old, "volume_db", SILENT_DB, FADE_S)
	if next != null:
		_active = 1 - _active
		var p := _players[_active]
		p.stream = next
		p.volume_db = SILENT_DB
		p.play()
		_fade.tween_property(p, "volume_db", _target_db(), FADE_S)
	if fade_old:
		_fade.chain().tween_callback(old.stop)


## A track ended on its own: chain straight into another random one.
func _on_finished(p: AudioStreamPlayer) -> void:
	if p != _players[_active] or current == &"" or not _playlists.has(current):
		return
	p.stream = _pick()
	p.volume_db = _target_db()
	p.play()


func _scan() -> void:
	var files: PackedStringArray = ResourceLoader.list_directory(MUSIC_DIR)
	files.sort()
	for f in files:
		if not f.ends_with(".ogg"):
			continue
		var base := f.get_basename()               # "lava_and_cave_3"
		var cut := base.rfind("_")
		if cut <= 0 or not base.substr(cut + 1).is_valid_int():
			continue
		var stream := load(MUSIC_DIR + f) as AudioStream
		if stream == null:
			continue
		if stream is AudioStreamOggVorbis:
			(stream as AudioStreamOggVorbis).loop = false   # we chain tracks ourselves
		var key := StringName(base.substr(0, cut))
		if not _playlists.has(key):
			_playlists[key] = []
		(_playlists[key] as Array).append(stream)
