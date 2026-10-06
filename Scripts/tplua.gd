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
	var cena_atual := get_tree().current_scene
	var pixel_fade := cena_atual.get_node_or_null("ColorRect/PixelFade")

	if pixel_fade != null and pixel_fade.has_method("trocar_fase"):
		pixel_fade.trocar_fase(cena_destino)
	else:
		push_warning("PixelFade não encontrado. Trocando de cena sem shader.")
		get_tree().change_scene_to_file(cena_destino)
