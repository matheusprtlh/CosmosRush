
extends CanvasLayer

# === CONFIGURAÇÕES DO ALARME ===
@export var tempo_ate_tremor: float = 8.0
@export var tempo_ate_preto: float = 16.0
@export var tempo_tela_preta: float = 3.0

@export var periodo_pisca: float = 1.2
@export var intensidade_vermelho: float = 0.35

# === CONFIGURAÇÕES DO TREMOR ===
@export var camera: Camera2D
@export var intensidade_tremor: float = 5.0
@export var velocidade_tremor: float = 30.0

# === REFERÊNCIAS ===
var tela_vermelha: ColorRect
var tela_preta: ColorRect

# === CONTROLE ===
var tempo: float = 0.0
var tela_escureceu: bool = false
var posicao_original_camera: Vector2 = Vector2.ZERO


func _ready() -> void:
	layer = 100

	# Encontra a câmera automaticamente
	if camera == null:
		camera = get_viewport().get_camera_2d()

	if camera != null:
		posicao_original_camera = camera.offset

	# === ALARME VERMELHO ===
	tela_vermelha = ColorRect.new()
	tela_vermelha.name = "TelaVermelha"
	tela_vermelha.color = Color(1.0, 0.0, 0.0, 0.0)
	tela_vermelha.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	tela_vermelha.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tela_vermelha)

	# === TELA PRETA ===
	tela_preta = ColorRect.new()
	tela_preta.name = "TelaPreta"
	tela_preta.color = Color.BLACK
	tela_preta.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	tela_preta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tela_preta.visible = false
	add_child(tela_preta)


func _process(delta: float) -> void:
	if tela_escureceu:
		return

	tempo += delta

	# === AOS 16 SEGUNDOS: TELA PRETA ===
	if tempo >= tempo_ate_preto:
		deixar_tela_preta()
		return

	# === VELOCIDADE DO ALARME ===
	var periodo_atual: float = periodo_pisca

	if tempo >= tempo_ate_tremor:
		periodo_atual = periodo_pisca / 2.0

	# === ALARME VERMELHO ===
	var oscilacao: float = (
		sin(tempo * TAU / periodo_atual) + 1.0
	) / 2.0

	tela_vermelha.color.a = (
		oscilacao * intensidade_vermelho
	)

	# === TREMOR DA CÂMERA ===
	if camera != null:
		if tempo >= tempo_ate_tremor:
			var tremor_x: float = (
				sin(tempo * velocidade_tremor) *
				intensidade_tremor
			)

			var tremor_y: float = (
				cos(tempo * velocidade_tremor * 1.37) *
				intensidade_tremor
			)

			camera.offset = (
				posicao_original_camera +
				Vector2(tremor_x, tremor_y)
			)
		else:
			camera.offset = posicao_original_camera


func parar_tremor() -> void:
	if is_instance_valid(camera):
		camera.offset = posicao_original_camera


func deixar_tela_preta() -> void:
	tela_escureceu = true

	# Para o tremor
	parar_tremor()

	# Desliga o alarme vermelho
	tela_vermelha.visible = false

	# Ativa a tela preta
	tela_preta.visible = true

	print("Tela preta ativada aos 16 segundos!")

	# Aguarda 3 segundos
	await get_tree().create_timer(tempo_tela_preta).timeout

	# Troca para a Terra
	get_tree().change_scene_to_file(
		"res://Cenas/terra_1.tscn"
	)


func _exit_tree() -> void:
	parar_tremor()
