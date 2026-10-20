extends Area2D

@export_file("*.tscn") var cena_destino: String
var trocando: bool = false

func _on_body_entered(body: Node2D) -> void:
	if trocando:
		return
	if not body is CharacterBody2D:
		return
	if cena_destino.is_empty():
		push_error("Portal da Lua sem cena_destino configurada: " + name)
		return

	trocando = true
	TransicaoGlobal.get_node("PixelFade").trocar_fase(cena_destino)
