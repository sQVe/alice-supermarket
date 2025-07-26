extends Node

# GameManager Singleton - Central coordinator for all game systems.
# Purpose: Initialize and coordinate all core managers for Alice Supermarket educational game.

signal game_ready
signal scene_changed(scene_name: String)
signal player_profile_changed(profile: Resource)

# Core manager references.
var scene_manager: Node
var audio_manager: Node
var data_manager: Node
var localization_manager: Node

# Current game state.
var current_player: Resource
var is_initialized: bool = false

# Manager registry for dynamic access.
var managers: Dictionary = {}

func _ready():
	initialize()

func initialize():
	"""Initialize all core game managers in proper order"""
	if is_initialized:
		return

	print("[GameManager] Initializing core game systems...")

	# Register this manager first.
	managers["game"] = self
	
	# Initialize SceneManager (created in task 2).
	if SceneManager:
		scene_manager = SceneManager
		managers["scene"] = scene_manager
		print("[GameManager] SceneManager registered")
	
	# Initialize DataManager (created in task 3).
	if DataManager:
		data_manager = DataManager
		managers["data"] = data_manager
		print("[GameManager] DataManager registered")

	# Initialize managers will be added as they are created in subsequent tasks.

	is_initialized = true
	game_ready.emit()
	print("[GameManager] Game systems initialized successfully")

func get_manager(manager_name: String) -> Node:
	"""Get a registered manager by name"""
	if manager_name in managers:
		return managers[manager_name]
	else:
		push_warning("[GameManager] Manager '%s' not found" % manager_name)
		return null

func register_manager(name: String, manager: Node):
	"""Register a manager for centralized access"""
	if name in managers:
		push_warning("[GameManager] Manager '%s' already registered, overwriting" % name)

	managers[name] = manager
	print("[GameManager] Registered manager: %s" % name)

func set_current_player(profile: Resource):
	"""Set the current active player profile"""
	if current_player != profile:
		current_player = profile
		player_profile_changed.emit(profile)
		print("[GameManager] Player profile changed: %s" % (profile.name if profile else "None"))

func get_current_player() -> Resource:
	"""Get the current active player profile"""
	return current_player

func on_scene_changed(scene_name: String):
	"""Handle scene change events from SceneManager"""
	scene_changed.emit(scene_name)
	print("[GameManager] Scene changed to: %s" % scene_name)

func shutdown():
	"""Gracefully shutdown all game systems"""
	print("[GameManager] Shutting down game systems...")

	# Notify all managers to cleanup.
	for manager_name in managers:
		var manager = managers[manager_name]
		if manager != self and manager.has_method("shutdown"):
			manager.shutdown()

	is_initialized = false
	print("[GameManager] Game systems shutdown complete")
