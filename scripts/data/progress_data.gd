class_name ProgressData
extends Resource

@export var math_level: int = 0
@export var reading_level: int = 0
@export var writing_level: int = 0
@export var total_play_time: float = 0.0
@export var achievements: Array[String] = []
@export var completed_activities: Dictionary = {}

func _init():
	initialize_default_values()

func initialize_default_values():
	if math_level == 0:
		math_level = 1
	if reading_level == 0:
		reading_level = 1
	if writing_level == 0:
		writing_level = 1
	if achievements.is_empty():
		achievements = []
	if completed_activities.is_empty():
		completed_activities = {}

func add_play_time(time_seconds: float):
	total_play_time += time_seconds

func unlock_achievement(achievement_id: String):
	if not achievements.has(achievement_id):
		achievements.append(achievement_id)

func complete_activity(activity_id: String, score: float, completion_time: float):
	completed_activities[activity_id] = {
		"score": score,
		"completion_time": completion_time,
		"completed_at": Time.get_unix_time_from_system()
	}

func get_skill_level(skill_type: String) -> int:
	match skill_type.to_lower():
		"math":
			return math_level
		"reading":
			return reading_level
		"writing":
			return writing_level
		_:
			return 0

func advance_skill_level(skill_type: String, amount: int = 1):
	match skill_type.to_lower():
		"math":
			math_level = max(1, math_level + amount)
		"reading":
			reading_level = max(1, reading_level + amount)
		"writing":
			writing_level = max(1, writing_level + amount)

func get_activity_completion(activity_id: String) -> Dictionary:
	return completed_activities.get(activity_id, {})

func is_activity_completed(activity_id: String) -> bool:
	return completed_activities.has(activity_id)

func get_total_activities_completed() -> int:
	return completed_activities.size()

func calculate_overall_progress() -> float:
	"""Calculate overall progress as a percentage (0.0 to 1.0) based on skill levels."""
	var total_levels = math_level + reading_level + writing_level
	# Maximum expected level per skill is 10, so total possible is 30
	# This represents mastery across all three educational domains
	var max_possible = 30.0
	return min(1.0, total_levels / max_possible)

func get_achievements_count() -> int:
	return achievements.size()

func validate_progress_data() -> bool:
	if math_level < 1 or reading_level < 1 or writing_level < 1:
		return false
	if total_play_time < 0:
		return false
	return true

func reset_progress():
	math_level = 1
	reading_level = 1
	writing_level = 1
	total_play_time = 0.0
	achievements.clear()
	completed_activities.clear()