
extends CanvasLayer

# === CONFIGURAÇÕES ===
@export var duracao_fade: float = 5.0
@export var iniciar_automaticamente: bool = true

var tela_preta: ColorRect


func _ready() -> void:
	# Coloca o fade acima dos outros efeitos
	layer = 100

	# Cria a tela preta automaticamente
	tela_preta = ColorRect.new()
	tela_preta.name = "TelaPreta"
	tela_preta.color = Color.BLACK
	tela_preta.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(tela_preta)

	# Preenche a tela inteira
	tela_preta.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	if iniciar_automaticamente:
		iniciar_fade()
	else:
		tela_preta.color.a = 0.0


func iniciar_fade() -> void:
	# Começa totalmente preto
	tela_preta.color.a = 1.0

	# Revela a cena gradualmente
	var tween = create_tween()
	tween.tween_property(
		tela_preta,
		"color:a",
		0.0,
		duracao_fade
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

	tela_preta.visible = false
