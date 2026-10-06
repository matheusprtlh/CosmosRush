extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		get_tree().current_scene.get_node("ColorRect/PixelFade").trocar_fase("res://Cenas/marte_3.tscn")
