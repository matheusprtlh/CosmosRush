extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		TransicaoGlobal.get_node("PixelFade").trocar_fase("res://Cenas/terra_2.tscn")
