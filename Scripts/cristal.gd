extends Area2D

var coletado: bool = false

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if coletado:
		return

	if body is CharacterBody2D:
		coletado = true
		Gamedata.coletar_cristal()

		if body.has_method("atualizar_hud_cristais"):
			body.atualizar_hud_cristais()

		queue_free()
