extends Control

func _on_start_button_pressed():
	# TODO: Load game scene
	print("Start game pressed")

func _on_settings_button_pressed():
	# TODO: Load settings scene
	print("Settings pressed")

func _on_exit_button_pressed():
	get_tree().quit()