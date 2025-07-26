class_name PlayerProfile
extends Resource

# Used by GameManager to track current player state and educational progress.

@export var id: String = ""
@export var name: String = ""
@export var avatar: String = "default"
@export var language: String = "en"
@export var created_date: String = ""
@export var last_played: String = ""
@export var settings: Dictionary = {}
@export var progress: Resource

const DEFAULT_AVATARS: Array[String] = ["default", "alice", "chef", "explorer"]
const SUPPORTED_LANGUAGES: Array[String] = ["en", "sv"]

func _init():
	if settings.is_empty():
		settings = get_default_settings()

static func get_default_settings() -> Dictionary:
	return {
		"master_volume": 1.0,
		"sfx_volume": 1.0,
		"music_volume": 0.7,
		"tts_enabled": true,
		"accessibility_mode": false,
		"tutorial_completed": false
	}

func validate() -> bool:
	"""Validate profile data integrity and fix recoverable issues."""
	var is_valid = true

	if id.is_empty():
		push_error("[PlayerProfile] Profile ID cannot be empty")
		is_valid = false

	if name.is_empty():
		push_warning("[PlayerProfile] Profile name is empty, using default")
		name = "Player"

	if not avatar in DEFAULT_AVATARS:
		push_warning("[PlayerProfile] Invalid avatar '%s', using default" % avatar)
		avatar = "default"

	if not language in SUPPORTED_LANGUAGES:
		push_warning("[PlayerProfile] Unsupported language '%s', using English" % language)
		language = "en"

	if created_date.is_empty():
		push_warning("[PlayerProfile] Created date is empty, using current time")
		created_date = Time.get_datetime_string_from_system()

	if last_played.is_empty():
		last_played = created_date

	var default_settings = get_default_settings()
	for key in default_settings:
		if not settings.has(key):
			settings[key] = default_settings[key]
			push_warning("[PlayerProfile] Missing setting '%s', using default" % key)

	validate_settings()

	return is_valid

func validate_settings():
	for volume_key in ["master_volume", "sfx_volume", "music_volume"]:
		if settings.has(volume_key):
			var volume = settings[volume_key]
			if not volume is float and not volume is int:
				settings[volume_key] = 1.0
				push_warning("[PlayerProfile] Invalid %s value, using 1.0" % volume_key)
			else:
				settings[volume_key] = clampf(volume, 0.0, 1.0)

	for bool_key in ["tts_enabled", "accessibility_mode", "tutorial_completed"]:
		if settings.has(bool_key) and not settings[bool_key] is bool:
			settings[bool_key] = get_default_settings()[bool_key]
			push_warning("[PlayerProfile] Invalid %s value, using default" % bool_key)

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"avatar": avatar,
		"language": language,
		"created_date": created_date,
		"last_played": last_played,
		"settings": settings.duplicate()
		# Progress data requires ProgressData class to be completed first for proper serialization
	}

static func from_dict(data: Dictionary) -> PlayerProfile:
	var profile = PlayerProfile.new()

	profile.id = data.get("id", "")
	profile.name = data.get("name", "")
	profile.avatar = data.get("avatar", "default")
	profile.language = data.get("language", "en")
	profile.created_date = data.get("created_date", "")
	profile.last_played = data.get("last_played", "")
	profile.settings = data.get("settings", {})

	var default_settings = get_default_settings()
	for key in default_settings:
		if not profile.settings.has(key):
			profile.settings[key] = default_settings[key]

	profile.validate()

	return profile

func get_display_name() -> String:
	return name if not name.is_empty() else "Unknown Player"

func get_play_time_formatted() -> String:
	if created_date.is_empty() or last_played.is_empty():
		return "Unknown"

	# Simple duration calculation (this could be enhanced with actual play time tracking)
	return "Since " + created_date.split("T")[0]

func is_tutorial_completed() -> bool:
	return settings.get("tutorial_completed", false)

func set_tutorial_completed():
	settings["tutorial_completed"] = true

func get_volume_setting(volume_type: String) -> float:
	var default_settings = get_default_settings()
	if not default_settings.has(volume_type):
		push_warning("[PlayerProfile] Unknown volume type: %s" % volume_type)
		return 1.0

	return settings.get(volume_type, default_settings[volume_type])

func set_volume_setting(volume_type: String, volume: float):
	var default_settings = get_default_settings()
	if not default_settings.has(volume_type):
		push_warning("[PlayerProfile] Unknown volume type: %s" % volume_type)
		return

	settings[volume_type] = clampf(volume, 0.0, 1.0)

func update_last_played():
	last_played = Time.get_datetime_string_from_system()
