extends Control

@onready var som_click: AudioStreamPlayer = $SomClick


func _on_button_pressed() -> void:
	await tocar_click()
	get_tree().change_scene_to_file("res://Cenas/terra_1.tscn")


func _on_button_2_pressed() -> void:
	await tocar_click()
	get_tree().quit()


func tocar_click() -> void:
	som_click.play()
	await get_tree().create_timer(0.08).timeout
