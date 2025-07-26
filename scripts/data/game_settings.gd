class_name GameSettings
extends Resource

# Core audio settings.
@export var master_volume: float = 1.0
@export var sfx_volume: float = 1.0
@export var music_volume: float = 0.7  # Default to 70% for pleasant background music
@export var tts_enabled: bool = true

# Localization and accessibility.
@export var language: String = "en"
@export var accessibility_mode: bool = false

# Progress tracking.
@export var tutorial_completed: bool = false
@export var parental_controls_enabled: bool = false

# Constants for validation and configuration.
const SUPPORTED_LANGUAGES: Array[String] = ["en", "sv"]
const MIN_VOLUME: float = 0.0
const MAX_VOLUME: float = 1.0
const ACCESSIBILITY_MIN_VOLUME: float = 0.8  # Minimum volume for accessibility compliance


func _init():
	initialize_default_values()

func initialize_default_values():
	"""Initialize settings with system-appropriate defaults."""
	if language.is_empty() or not language in SUPPORTED_LANGUAGES:
		language = detect_system_language()
	
	validate()

static func detect_system_language() -> String:
	"""Detect system language with fallback to English."""
	var system_locale = OS.get_locale_language()
	if system_locale in SUPPORTED_LANGUAGES:
		return system_locale
	return "en"

func validate() -> bool:
	"""Validate all settings and fix invalid values with appropriate defaults."""
	var is_valid = true
	
	master_volume = clampf(master_volume, MIN_VOLUME, MAX_VOLUME)
	sfx_volume = clampf(sfx_volume, MIN_VOLUME, MAX_VOLUME)
	music_volume = clampf(music_volume, MIN_VOLUME, MAX_VOLUME)
	
	if not language in SUPPORTED_LANGUAGES:
		push_warning("[GameSettings] Unsupported language '%s', using English" % language)
		language = "en"
		is_valid = false
	
	if not tts_enabled is bool:
		push_warning("[GameSettings] Invalid tts_enabled value, using true")
		tts_enabled = true
		is_valid = false
	
	if not accessibility_mode is bool:
		push_warning("[GameSettings] Invalid accessibility_mode value, using false")
		accessibility_mode = false
		is_valid = false
	
	if not tutorial_completed is bool:
		push_warning("[GameSettings] Invalid tutorial_completed value, using false")
		tutorial_completed = false
		is_valid = false
	
	if not parental_controls_enabled is bool:
		push_warning("[GameSettings] Invalid parental_controls_enabled value, using false")
		parental_controls_enabled = false
		is_valid = false
	
	return is_valid

func get_default_settings() -> Dictionary:
	"""Get factory default settings dictionary."""
	return {
		"master_volume": 1.0,
		"sfx_volume": 1.0,
		"music_volume": 0.7,
		"tts_enabled": true,
		"language": detect_system_language(),
		"accessibility_mode": false,
		"tutorial_completed": false,
		"parental_controls_enabled": false
	}

func reset_to_defaults():
	"""Reset all settings to factory defaults."""
	var defaults = get_default_settings()
	master_volume = defaults.master_volume
	sfx_volume = defaults.sfx_volume
	music_volume = defaults.music_volume
	tts_enabled = defaults.tts_enabled
	language = defaults.language
	accessibility_mode = defaults.accessibility_mode
	tutorial_completed = defaults.tutorial_completed
	parental_controls_enabled = defaults.parental_controls_enabled


func set_volume(volume_type: String, volume: float) -> bool:
	"""Set volume for specified audio type with validation."""
	volume = clampf(volume, MIN_VOLUME, MAX_VOLUME)
	
	match volume_type.to_lower():
		"master":
			master_volume = volume
			return true
		"sfx", "sound":
			sfx_volume = volume
			return true
		"music":
			music_volume = volume
			return true
		_:
			push_warning("[GameSettings] Unknown volume type: %s" % volume_type)
			return false

func get_volume(volume_type: String) -> float:
	"""Get volume for specified audio type."""
	match volume_type.to_lower():
		"master":
			return master_volume
		"sfx", "sound":
			return sfx_volume
		"music":
			return music_volume
		_:
			push_warning("[GameSettings] Unknown volume type: %s" % volume_type)
			return 1.0

func get_effective_volume(volume_type: String) -> float:
	"""Get the final volume after applying master volume multiplier."""
	var base_volume = get_volume(volume_type)
	return base_volume * master_volume


func is_language_supported(language_code: String) -> bool:
	"""Check if a language code is supported by the game."""
	return language_code in SUPPORTED_LANGUAGES

func set_language(language_code: String) -> bool:
	"""Set game language with validation."""
	if is_language_supported(language_code):
		language = language_code
		return true
	else:
		push_warning("[GameSettings] Unsupported language: %s" % language_code)
		return false


func enable_accessibility_features():
	"""Enable accessibility features with appropriate audio settings."""
	accessibility_mode = true
	tts_enabled = true
	# Ensure minimum volume for accessibility compliance (hearing impaired users)
	master_volume = max(master_volume, ACCESSIBILITY_MIN_VOLUME)

func disable_accessibility_features():
	"""Disable accessibility mode (but preserve individual accessibility settings)."""
	accessibility_mode = false

func is_audio_enabled() -> bool:
	"""Check if audio is enabled (master volume > 0)."""
	return master_volume > 0.0

func has_parental_restrictions() -> bool:
	"""Check if parental controls are currently active."""
	return parental_controls_enabled

func mark_tutorial_completed():
	"""Mark the tutorial as completed for this settings profile."""
	tutorial_completed = true

func is_tutorial_completed() -> bool:
	"""Check if the tutorial has been completed."""
	return tutorial_completed


func to_dict() -> Dictionary:
	"""Convert settings to dictionary for JSON serialization."""
	return {
		"master_volume": master_volume,
		"sfx_volume": sfx_volume,
		"music_volume": music_volume,
		"tts_enabled": tts_enabled,
		"language": language,
		"accessibility_mode": accessibility_mode,
		"tutorial_completed": tutorial_completed,
		"parental_controls_enabled": parental_controls_enabled
	}

static func from_dict(data: Dictionary) -> GameSettings:
	"""Create GameSettings instance from dictionary with validation."""
	var settings = GameSettings.new()
	
	settings.master_volume = data.get("master_volume", 1.0)
	settings.sfx_volume = data.get("sfx_volume", 1.0)
	settings.music_volume = data.get("music_volume", 0.7)
	settings.tts_enabled = data.get("tts_enabled", true)
	settings.language = data.get("language", detect_system_language())
	settings.accessibility_mode = data.get("accessibility_mode", false)
	settings.tutorial_completed = data.get("tutorial_completed", false)
	settings.parental_controls_enabled = data.get("parental_controls_enabled", false)
	
	settings.validate()
	
	return settings