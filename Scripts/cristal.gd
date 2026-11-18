extends Area2D

var coletado: bool = false


func _ready() -> void:
	# As duas instâncias do cristal azul compartilham o mesmo tipo.
	if Gamedata.cristal_coletado(scene_file_path):
		queue_free()
		return
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if coletado or not body is CosmosPlayer or not body.pode_interagir():
		return

	coletado = true
	Gamedata.coletar_cristal(scene_file_path)
	body.atualizar_hud_cristais()
	queue_free()
