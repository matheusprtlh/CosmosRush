
extends CanvasLayer

# === CONFIGURAÇÕES ===
@export var duracao_despertar: float = 5.0
@export var intensidade_tremor: float = 3.0
@export var velocidade_tremor: float = 18.0

@export var camera: Camera2D

# === REFERÊNCIAS ===
var tela_preta: ColorRect

# === CONTROLE ===
var tempo: float = 0.0
var terminou: bool = false
var posicao_original_camera: Vector2 = Vector2.ZERO


func _ready() -> void:
	layer = 100

	# Localiza a câmera
	if camera == null:
		camera = get_viewport().get_camera_2d()

	if camera != null:
		posicao_original_camera = camera.offset

	# Cria a tela preta
	tela_preta = ColorRect.new()
	tela_preta.name = "TelaPreta"
	tela_preta.color = Color.BLACK
	tela_preta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tela_preta.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	add_child(tela_preta)

	# Começa totalmente preto
	tela_preta.color.a = 1.0


func _process(delta: float) -> void:
	if terminou:
		return

	tempo += delta

	# === DESPERTAR DURANTE 5 SEGUNDOS ===
	if tempo < duracao_despertar:
		efeito_olhos()
		aplicar_tremor()
	else:
		finalizar_despertar()


func efeito_olhos() -> void:
	# Alterna entre preto e pequenas aberturas
	var abertura: float = 0.0

	if tempo < 1.0:
		# Primeira tentativa de abrir os olhos
		abertura = sin(tempo * PI) * 0.35

	elif tempo < 2.3:
		# Segunda tentativa, um pouco maior
		var t: float = (tempo - 1.0) / 1.3
		abertura = sin(t * PI) * 0.60

	elif tempo < 4.2:
		# Terceira tentativa, quase acordando
		var t: float = (tempo - 2.3) / 1.9
		abertura = sin(t * PI) * 0.85

	else:
		# Última piscada antes de acordar
		abertura = 0.0

	tela_preta.color.a = 1.0 - abertura


func aplicar_tremor() -> void:
	if not is_instance_valid(camera):
		camera = get_viewport().get_camera_2d()

		if camera != null:
			posicao_original_camera = camera.offset

	if camera == null:
		return

	var tremor_x: float = (
		sin(tempo * velocidade_tremor) * 0.7 +
		sin(tempo * velocidade_tremor * 1.7) * 0.3
	) * intensidade_tremor

	var tremor_y: float = (
		cos(tempo * velocidade_tremor * 1.2) * 0.7 +
		cos(tempo * velocidade_tremor * 2.1) * 0.3
	) * intensidade_tremor

	camera.offset = (
		posicao_original_camera +
		Vector2(tremor_x, tremor_y)
	)


func finalizar_despertar() -> void:
	terminou = true

	# Para o tremor
	if is_instance_valid(camera):
		camera.offset = posicao_original_camera

	# Abre os olhos definitivamente
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		tela_preta,
		"color:a",
		0.0,
		0.8
	)

	await tween.finished

	tela_preta.queue_free()

	print("Astronauta acordou!")


func _exit_tree() -> void:
	if is_instance_valid(camera):
		camera.offset = posicao_original_camera
