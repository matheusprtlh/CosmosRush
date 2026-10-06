extends Label

@export var tempo_fade_in: float = 2.0
@export var tempo_visivel: float = 2.0
@export var tempo_fade_out: float = 2.0

func _ready() -> void:
	modulate.a = 0.0
	mostrar_nome()

func mostrar_nome() -> void:
	# Fade in
	var fade_in := create_tween()
	fade_in.tween_property(self, "modulate:a", 1.0, tempo_fade_in)
	await fade_in.finished

	# Fica visível
	await get_tree().create_timer(tempo_visivel).timeout

	# Fade out
	var fade_out := create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, tempo_fade_out)
	await fade_out.finished

	# Some completamente
	hide()
