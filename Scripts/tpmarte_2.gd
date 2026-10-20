extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		TransicaoGlobal.get_node("PixelFade").trocar_fase("res://Cenas/marte_2.tscn")
