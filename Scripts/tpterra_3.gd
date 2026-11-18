extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is CosmosPlayer and body.preparar_saida():
		body.concluir_saida("res://Cenas/terra_3.tscn")
