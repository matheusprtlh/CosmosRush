extends Area2D

signal capsula_coletada

@onready var som_oxigenio: AudioStreamPlayer = $SomOxigenio

var coletada: bool = false

# Configurações da flutuação
@export var altura_flutuacao: float = 8.0
@export var velocidade_flutuacao: float = 2.0

var posicao_inicial: Vector2
var tempo: float = 0.0
var fase_aleatoria: float
var velocidade_individual: float


func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	posicao_inicial = position

	# Cada cápsula começa em um ponto diferente da animação
	fase_aleatoria = randf_range(0.0, TAU)

	# Cada cápsula recebe uma velocidade diferente
	velocidade_individual = velocidade_flutuacao * randf_range(0.8, 1.2)


func _process(delta: float) -> void:
	if coletada:
		return

	tempo += delta * velocidade_individual

	position.y = posicao_inicial.y + sin(tempo + fase_aleatoria) * altura_flutuacao


func _on_body_entered(body: Node2D) -> void:
	if coletada or not body is CosmosPlayer or not body.recuperar_oxigenio():
		return

	coletada = true
	capsula_coletada.emit()
	hide()
	set_deferred("monitoring", false)

	som_oxigenio.play()
	await som_oxigenio.finished
	queue_free()
