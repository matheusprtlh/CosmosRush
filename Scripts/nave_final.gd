extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var colisao: CollisionShape2D = $CollisionShape2D
@onready var som_foguete: AudioStreamPlayer = $SomFoguete
@onready var final_musica: AudioStreamPlayer = $FinalMusica

var ativada: bool = false
var vibrando: bool = false
var subindo: bool = false
var posicao_original: Vector2

const TEMPO_VIBRACAO: float = 10.0
const INTENSIDADE_VIBRACAO: float = 3.0
const TEMPO_SUBIDA: float = 2.0
const VELOCIDADE_SUBIDA: float = 180.0

func _ready() -> void:
	posicao_original = position
	anim.play("idle")

func _process(delta: float) -> void:
	if vibrando:
		position = posicao_original + Vector2(
			randf_range(-INTENSIDADE_VIBRACAO, INTENSIDADE_VIBRACAO),
			randf_range(-INTENSIDADE_VIBRACAO, INTENSIDADE_VIBRACAO)
		)

	if subindo:
		position.y -= VELOCIDADE_SUBIDA * delta

func _on_body_entered(body: Node2D) -> void:
	if ativada or not body is CosmosPlayer or Gamedata.cristais < 4:
		return
	if not body.preparar_saida(true):
		return

	ativada = true
	colisao.set_deferred("disabled", true)
	som_foguete.play()
	final_musica.play()
	anim.play("decolar")

	vibrando = true
	await get_tree().create_timer(TEMPO_VIBRACAO, false).timeout
	vibrando = false
	position = posicao_original

	subindo = true
	await get_tree().create_timer(TEMPO_SUBIDA, false).timeout
	som_foguete.stop()
	final_musica.stop()


	if not await body.concluir_saida("res://Cenas/final.tscn"):
		subindo = false
		ativada = false
		position = posicao_original
		colisao.set_deferred("disabled", false)
		anim.play("idle")
