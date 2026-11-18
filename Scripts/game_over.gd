extends Control

func _on_button_pressed() -> void:
	Gamedata.resetar_jogo()
	get_tree().change_scene_to_file("res://Cenas/terra_1.tscn")


func _on_button_menu_pressed() -> void:
	Gamedata.resetar_jogo()
	get_tree().change_scene_to_file("res://Cenas/menu.tscn")
