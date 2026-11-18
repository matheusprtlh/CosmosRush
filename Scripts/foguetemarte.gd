extends Area2D

var ativado: bool = false
var vibrando: bool = false
var subindo: bool = false

var posicao_original: Vector2

const TEMPO_VIBRACAO: float = 2.0
const INTENSIDADE_VIBRACAO: float = 3.0
const TEMPO_SUBIDA: float = 2.0
const VELOCIDADE_SUBIDA: float = 250.0

@onready var som_foguete: AudioStreamPlayer = $SomFoguete

func _ready() -> void:
	posicao_original = position

func _process(delta: float) -> void:
	if vibrando:
		position = posicao_original + Vector2(
			randf_range(-INTENSIDADE_VIBRACAO, INTENSIDADE_VIBRACAO),
			randf_range(-INTENSIDADE_VIBRACAO, INTENSIDADE_VIBRACAO)
		)

	if subindo:
		position.y -= VELOCIDADE_SUBIDA * delta

func _on_body_entered(body: Node2D) -> void:
	if ativado or not body is CosmosPlayer:
		return
	if not body.preparar_saida(true):
		return

	ativado = true
	$CollisionShape2D.set_deferred("disabled", true)
	som_foguete.play()

	vibrando = true
	await get_tree().create_timer(TEMPO_VIBRACAO, false).timeout
	vibrando = false
	position = posicao_original

	subindo = true
	await get_tree().create_timer(TEMPO_SUBIDA, false).timeout

	if not await body.concluir_saida("res://Cenas/lua.tscn"):
		subindo = false
		ativado = false
		position = posicao_original
		$CollisionShape2D.set_deferred("disabled", false)
