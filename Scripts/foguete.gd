extends Area2D

@onready var som_foguete: AudioStreamPlayer = $SomFoguete

var ativado: bool = false
var tremendo: bool = false
var subindo: bool = false

var posicao_original: Vector2

@export var tempo_tremendo: float = 5.0
@export var intensidade_tremor: float = 3.0
@export var velocidade_subida: float = 250.0
@export var tempo_subida: float = 3.0

func _ready() -> void:
	posicao_original = position

func _process(delta: float) -> void:
	if tremendo:
		position = posicao_original + Vector2(
			randf_range(-intensidade_tremor, intensidade_tremor),
			randf_range(-intensidade_tremor, intensidade_tremor)
		)

	if subindo:
		position.y -= velocidade_subida * delta

func _on_body_entered(body: Node2D) -> void:
	if ativado or not body is CosmosPlayer:
		return
	if not body.preparar_saida(true):
		return

	ativado = true
	$CollisionShape2D.set_deferred("disabled", true)
	som_foguete.play()

	tremendo = true
	await get_tree().create_timer(tempo_tremendo, false).timeout
	tremendo = false
	position = posicao_original

	subindo = true
	await get_tree().create_timer(tempo_subida, false).timeout

	if not await body.concluir_saida("res://Cenas/marte.tscn"):
		subindo = false
		ativado = false
		position = posicao_original
		$CollisionShape2D.set_deferred("disabled", false)
