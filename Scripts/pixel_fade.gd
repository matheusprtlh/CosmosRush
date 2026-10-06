extends ColorRect

@export var duracao_entrada: float = 1.0
@export var tempo_preenchido: float = 0.5
@export var duracao_saida: float = 1.0

@onready var shader_material: ShaderMaterial = material as ShaderMaterial

var trocando_fase: bool = false


func _ready():
	# A nova fase começa totalmente coberta.
	shader_material.set_shader_parameter("progress", 1.0)

	# Espera um pouco com a tela coberta.
	await get_tree().create_timer(tempo_preenchido).timeout

	# Os pixels continuam o movimento e saem pela direita.
	await _animar_progress(1.0, 2.0, duracao_saida)


func trocar_fase(caminho_da_fase: String):
	# Impede a transição de ser chamada várias vezes.
	if trocando_fase:
		return

	trocando_fase = true

	# Começa sem pixels.
	shader_material.set_shader_parameter("progress", 0.0)

	# Pixels entram da esquerda.
	await _animar_progress(0.0, 1.0, duracao_entrada)

	# Troca a cena assim que a tela fica completamente coberta.
	# A NOVA fase segura o preto por 0,5 s no _ready() e depois
	# continua o movimento, fazendo os pixels saírem pela direita.
	get_tree().change_scene_to_file(caminho_da_fase)


func _animar_progress(
	inicio: float,
	fim: float,
	duracao: float
):
	var tween = create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_method(
		_set_progress,
		inicio,
		fim,
		duracao
	)

	await tween.finished


func _set_progress(valor: float):
	shader_material.set_shader_parameter("progress", valor)
