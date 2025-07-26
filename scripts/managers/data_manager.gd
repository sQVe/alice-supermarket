extends Node

# DataManager Singleton - Player data persistence and progress tracking.
# Purpose: Handle save/load operations with JSON serialization and error recovery.

# Preload PlayerProfile class.
const PlayerProfile = preload("res://scripts/data/player_profile.gd")

signal data_saved()
signal data_loaded()
signal profile_created(profile: Resource)

# Data storage paths.
const SAVE_DIRECTORY: String = "user://saves/"
const BACKUP_SUFFIX: String = ".backup"

# Save retry configuration.
const MAX_SAVE_RETRIES: int = 3
const SAVE_RETRY_DELAY: float = 0.1

# Profile ID generation.
const MAX_RANDOM_SUFFIX: int = 10000

# In-memory profile cache.
var loaded_profiles: Array = []
var is_initialized: bool = false

func _ready():
	initialize()

func initialize():
	if is_initialized:
		return

	print("[DataManager] Initializing data persistence system...")

	if not DirAccess.dir_exists_absolute(SAVE_DIRECTORY):
		var dir = DirAccess.open("user://")
		if dir:
			var result = dir.make_dir_recursive("saves")
			if result != OK:
				push_error("[DataManager] Failed to create save directory: %s" % result)
				return
		else:
			push_error("[DataManager] Failed to access user directory")
			return

	load_all_profiles()

	if GameManager:
		GameManager.register_manager("data", self)

	is_initialized = true
	print("[DataManager] Data manager initialized successfully")

func save_player_data(profile: Resource):
	if not profile:
		push_error("[DataManager] Cannot save null profile")
		return

	print("[DataManager] Saving player data for: %s" % profile.name)

	profile.last_played = Time.get_datetime_string_from_system()

	var success = false
	for attempt in range(MAX_SAVE_RETRIES):
		success = save_profile_to_file(profile)
		if success:
			break

		push_warning("[DataManager] Save attempt %d failed, retrying..." % (attempt + 1))
		await get_tree().create_timer(SAVE_RETRY_DELAY).timeout

	if success:
		update_profile_in_cache(profile)
		data_saved.emit()
		print("[DataManager] Player data saved successfully")
	else:
		push_error("[DataManager] Failed to save player data after %d attempts" % MAX_SAVE_RETRIES)

func save_profile_to_file(profile: Resource) -> bool:
	var profile_file_path = SAVE_DIRECTORY + profile.id + ".json"
	var backup_file_path = profile_file_path + BACKUP_SUFFIX

	if FileAccess.file_exists(profile_file_path):
		var dir = DirAccess.open(SAVE_DIRECTORY)
		if dir:
			dir.copy(profile_file_path.get_file(), backup_file_path.get_file())

	var profile_data = serialize_profile(profile)
	if not profile_data:
		return false

	var file = FileAccess.open(profile_file_path, FileAccess.WRITE)
	if not file:
		push_error("[DataManager] Failed to open file for writing: %s" % profile_file_path)
		return false

	var json_string = JSON.stringify(profile_data, "\t")
	file.store_string(json_string)
	file.close()

	# Verify save succeeded by reading back the file
	if not validate_saved_file(profile_file_path, profile.id):
		if FileAccess.file_exists(backup_file_path):
			var dir = DirAccess.open(SAVE_DIRECTORY)
			if dir:
				dir.copy(backup_file_path.get_file(), profile_file_path.get_file())
		return false

	return true

func load_player_data(profile_id: String) -> Resource:
	if profile_id.is_empty():
		push_warning("[DataManager] Cannot load profile with empty ID")
		return null

	print("[DataManager] Loading player data for ID: %s" % profile_id)

	for profile in loaded_profiles:
		if profile.id == profile_id:
			print("[DataManager] Profile loaded from cache")
			data_loaded.emit()
			return profile

	var profile = load_profile_from_file(profile_id)
	if profile:
		loaded_profiles.append(profile)
		data_loaded.emit()
		print("[DataManager] Profile loaded from file")

	return profile

func load_profile_from_file(profile_id: String) -> Resource:
	var profile_file_path = SAVE_DIRECTORY + profile_id + ".json"

	if not FileAccess.file_exists(profile_file_path):
		push_warning("[DataManager] Profile file not found: %s" % profile_file_path)
		return null

	var file = FileAccess.open(profile_file_path, FileAccess.READ)
	if not file:
		push_error("[DataManager] Failed to open profile file: %s" % profile_file_path)
		return null

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("[DataManager] Failed to parse JSON in file: %s" % profile_file_path)
		return null

	var profile_data = json.data
	if not validate_profile_data(profile_data):
		push_error("[DataManager] Invalid profile data in file: %s" % profile_file_path)
		return null

	return deserialize_profile(profile_data)

func create_new_profile(name: String, avatar: String, language: String) -> Resource:
	print("[DataManager] Creating new profile: %s" % name)

	var profile_id = generate_unique_profile_id()

	var profile = PlayerProfile.new()
	profile.id = profile_id
	profile.name = name
	profile.avatar = avatar
	profile.language = language
	profile.created_date = Time.get_datetime_string_from_system()
	profile.last_played = profile.created_date
	# Progress data requires ProgressData class to be completed first

	# Validate the profile (this will fix any invalid values and set defaults)
	if not profile.validate():
		push_error("[DataManager] Failed to create valid profile")
		return null

	save_player_data(profile)

	profile_created.emit(profile)
	print("[DataManager] New profile created successfully: %s" % profile_id)

	return profile

func get_all_profiles() -> Array:
	return loaded_profiles.duplicate()

func delete_profile(profile_id: String):
	if profile_id.is_empty():
		push_warning("[DataManager] Cannot delete profile with empty ID")
		return

	print("[DataManager] Deleting profile: %s" % profile_id)

	for i in range(loaded_profiles.size() - 1, -1, -1):
		if loaded_profiles[i].id == profile_id:
			loaded_profiles.remove_at(i)
			break

	var profile_file_path = SAVE_DIRECTORY + profile_id + ".json"
	if FileAccess.file_exists(profile_file_path):
		var dir = DirAccess.open(SAVE_DIRECTORY)
		if dir:
			var result = dir.remove(profile_file_path.get_file())
			if result == OK:
				print("[DataManager] Profile file deleted successfully")
			else:
				push_error("[DataManager] Failed to delete profile file: %s" % result)

func load_all_profiles():
	"""Load all existing profiles from the save directory."""
	loaded_profiles.clear()

	var dir = DirAccess.open(SAVE_DIRECTORY)
	if not dir:
		print("[DataManager] Save directory not found, will create on first save")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".json") and not file_name.ends_with(BACKUP_SUFFIX):
			var profile_id = file_name.get_basename()
			var profile = load_profile_from_file(profile_id)
			if profile:
				loaded_profiles.append(profile)

		file_name = dir.get_next()

	print("[DataManager] Loaded %d profiles from disk" % loaded_profiles.size())

func serialize_profile(profile: Resource) -> Dictionary:
	if not profile:
		return {}

	# Use PlayerProfile's own serialization method for consistency
	return profile.to_dict()

func deserialize_profile(data: Dictionary) -> Resource:
	# Use PlayerProfile's static deserialization method with built-in validation
	return PlayerProfile.from_dict(data)

func validate_profile_data(data: Dictionary) -> bool:
	"""Validate that profile data contains required fields."""
	var required_fields = ["id", "name", "language", "created_date"]

	for field in required_fields:
		if not data.has(field) or data[field] == null:
			push_error("[DataManager] Missing required field: %s" % field)
			return false

		if data[field] is String and data[field].is_empty():
			push_error("[DataManager] Empty required field: %s" % field)
			return false

	return true

func validate_saved_file(file_path: String, expected_id: String) -> bool:
	"""Validate that a saved file can be loaded and has the correct ID."""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(json_string) != OK:
		return false

	var data = json.data
	if not data.has("id") or data["id"] != expected_id:
		return false

	return validate_profile_data(data)

func generate_unique_profile_id() -> String:
	"""Generate a unique profile ID."""
	var timestamp = Time.get_unix_time_from_system()
	var random_suffix = randi() % MAX_RANDOM_SUFFIX
	return "profile_%d_%04d" % [timestamp, random_suffix]

func update_profile_in_cache(profile: Resource):
	"""Update a profile in the loaded profiles cache."""
	for i in range(loaded_profiles.size()):
		if loaded_profiles[i].id == profile.id:
			loaded_profiles[i] = profile
			return

	# If not found in cache, add it.
	loaded_profiles.append(profile)

func get_save_directory_size() -> int:
	"""Get the total size of the save directory in bytes."""
	var total_size = 0
	var dir = DirAccess.open(SAVE_DIRECTORY)

	if not dir:
		return 0

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir():
			var file_path = SAVE_DIRECTORY + file_name
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				total_size += file.get_length()
				file.close()

		file_name = dir.get_next()

	return total_size

func shutdown():
	"""Clean up resources when shutting down."""
	# Save any pending changes.
	for profile in loaded_profiles:
		if profile:
			save_profile_to_file(profile)

	loaded_profiles.clear()
	is_initialized = false
	print("[DataManager] Shutdown complete")
