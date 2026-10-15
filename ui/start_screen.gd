extends Control

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://main/the_open_wastes.tscn")


func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://ui/options_screen.tscn")


func _on_exit_button_pressed():
	get_tree().quit()
