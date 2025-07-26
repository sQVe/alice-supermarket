class_name PlayerProfile
extends Resource

# PlayerProfile - Data structure for player information and progress.
# Used by GameManager to track current player state.

@export var id: String
@export var name: String
@export var avatar: String
@export var language: String
@export var created_date: String
@export var last_played: String
@export var settings: Dictionary
@export var progress: Resource

# Note: ProgressData will be implemented in task 5.
