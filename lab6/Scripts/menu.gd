extends Control

func _on_play_pressed():
	# Ładujemy główną scenę gry
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_exit_pressed():
	# Wyłączamy aplikację
	get_tree().quit()
