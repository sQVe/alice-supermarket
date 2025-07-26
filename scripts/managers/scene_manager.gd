extends Node

# SceneManager Singleton - Handle scene transitions with loading feedback.
# Purpose: Manage smooth scene transitions with fade effects and error handling.

# Transition timing constants.
const TRANSITION_DURATION: float = 0.3

signal scene_load_started(scene_path: String)
signal scene_load_progress(progress: float)
signal scene_load_completed(scene_name: String)
signal scene_load_failed(scene_path: String, error: String)

# Current scene tracking.
var current_scene: Node
var current_scene_name: String = ""

# Preloaded scenes cache.
var preloaded_scenes: Dictionary = {}

# Transition overlay for fade effects.
var transition_overlay: ColorRect
var transition_tween: Tween

# Loading state.
var is_loading: bool = false

func _ready():
	# Set initial scene reference.
	current_scene = get_tree().current_scene
	if current_scene:
		current_scene_name = current_scene.scene_file_path.get_file().get_basename()

	# Create transition overlay for fade effects.
	setup_transition_overlay()

	# Register with GameManager.
	if GameManager:
		GameManager.register_manager("scene", self)

	print("[SceneManager] Initialized - Current scene: %s" % current_scene_name)

func setup_transition_overlay():
	"""Create a full-screen overlay for fade transitions"""
	transition_overlay = ColorRect.new()
	transition_overlay.name = "TransitionOverlay"
	transition_overlay.color = Color.BLACK
	transition_overlay.modulate.a = 0.0
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Add to scene tree at root level to ensure it's always on top.
	get_tree().root.add_child(transition_overlay)

	# Set to full screen.
	transition_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Tween will be created as needed using create_tween().

func change_scene(scene_path: String, transition_type: String = "fade"):
	"""Change to a new scene with the specified transition type"""
	if is_loading:
		push_warning("[SceneManager] Scene change already in progress")
		return

	print("[SceneManager] Changing scene to: %s" % scene_path)
	scene_load_started.emit(scene_path)
	is_loading = true

	# Start transition based on type.
	match transition_type:
		"fade":
			await fade_transition(scene_path)
		"instant":
			await instant_transition(scene_path)
		_:
			push_warning("[SceneManager] Unknown transition type: %s, using fade" % transition_type)
			await fade_transition(scene_path)

func fade_transition(scene_path: String):
	"""Perform a fade-out, load scene, fade-in transition"""
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	transition_tween = create_tween()
	transition_tween.tween_property(transition_overlay, "modulate:a", 1.0, TRANSITION_DURATION)
	await transition_tween.finished

	# Load the new scene.
	var success = await load_scene_internal(scene_path)

	if success:
		transition_tween = create_tween()
		transition_tween.tween_property(transition_overlay, "modulate:a", 0.0, TRANSITION_DURATION)
		await transition_tween.finished
	else:
		transition_tween = create_tween()
		transition_tween.tween_property(transition_overlay, "modulate:a", 0.0, TRANSITION_DURATION)
		await transition_tween.finished

	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_loading = false

func instant_transition(scene_path: String):
	"""Perform an instant scene change without transition effects"""
	await load_scene_internal(scene_path)
	is_loading = false

func load_scene_internal(scene_path: String) -> bool:
	"""Internal method to handle the actual scene loading"""
	var new_scene: PackedScene

	# Check if scene is preloaded.
	if scene_path in preloaded_scenes:
		new_scene = preloaded_scenes[scene_path]
		print("[SceneManager] Using preloaded scene: %s" % scene_path)
	else:
		# Load scene from disk.
		if ResourceLoader.exists(scene_path):
			new_scene = load(scene_path)
		else:
			handle_scene_load_error(scene_path, "Scene file not found: %s" % scene_path)
			return false

	if not new_scene:
		handle_scene_load_error(scene_path, "Failed to load scene resource: %s" % scene_path)
		return false

	# Instantiate the new scene.
	var new_scene_instance = new_scene.instantiate()
	if not new_scene_instance:
		handle_scene_load_error(scene_path, "Failed to instantiate scene: %s" % scene_path)
		return false

	# Replace current scene.
	if current_scene and is_instance_valid(current_scene):
		current_scene.queue_free()

	get_tree().root.add_child(new_scene_instance)
	get_tree().current_scene = new_scene_instance
	current_scene = new_scene_instance
	current_scene_name = scene_path.get_file().get_basename()

	# Emit completion signal.
	scene_load_completed.emit(current_scene_name)

	# Notify GameManager of scene change.
	if GameManager:
		GameManager.on_scene_changed(current_scene_name)

	print("[SceneManager] Scene loaded successfully: %s" % current_scene_name)
	return true

func handle_scene_load_error(scene_path: String, error_message: String):
	"""Handle scene loading errors with fallback to main menu"""
	push_error("[SceneManager] %s" % error_message)
	scene_load_failed.emit(scene_path, error_message)

	# Attempt to return to main menu as fallback.
	var main_menu_path = "res://scenes/main_menu.tscn"
	if scene_path != main_menu_path and ResourceLoader.exists(main_menu_path):
		print("[SceneManager] Falling back to main menu")
		await load_scene_internal(main_menu_path)
	else:
		push_error("[SceneManager] Critical error: Cannot load fallback scene")

func preload_scene(scene_path: String):
	"""Preload a scene for faster transitions"""
	if scene_path in preloaded_scenes:
		print("[SceneManager] Scene already preloaded: %s" % scene_path)
		return

	if not ResourceLoader.exists(scene_path):
		push_warning("[SceneManager] Cannot preload non-existent scene: %s" % scene_path)
		return

	var scene = load(scene_path)
	if scene:
		preloaded_scenes[scene_path] = scene
		print("[SceneManager] Preloaded scene: %s" % scene_path)
	else:
		push_warning("[SceneManager] Failed to preload scene: %s" % scene_path)

func unload_preloaded_scene(scene_path: String):
	"""Remove a scene from the preloaded cache"""
	if scene_path in preloaded_scenes:
		preloaded_scenes.erase(scene_path)
		print("[SceneManager] Unloaded preloaded scene: %s" % scene_path)

func get_current_scene_name() -> String:
	"""Get the name of the current scene"""
	return current_scene_name

func get_current_scene() -> Node:
	"""Get the current scene node"""
	return current_scene

func clear_preloaded_scenes():
	"""Clear all preloaded scenes to free memory"""
	var count = preloaded_scenes.size()
	preloaded_scenes.clear()
	print("[SceneManager] Cleared %d preloaded scenes" % count)

func shutdown():
	"""Clean up resources when shutting down"""
	clear_preloaded_scenes()

	if transition_overlay and is_instance_valid(transition_overlay):
		transition_overlay.queue_free()

	# Tweens created with create_tween() are automatically cleaned up.

	print("[SceneManager] Shutdown complete")
