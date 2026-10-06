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
	if ativada:
		return

	if not body is CharacterBody2D:
		return

	if Gamedata.cristais < 4:
		print("Faltam cristais! ", Gamedata.cristais, "/4")
		return

	ativada = true

	# Player desaparece
	body.visible = false
	body.set_physics_process(false)

	# Desativa a colisão
	colisao.set_deferred("disabled", true)

	# Sons da decolagem
	som_foguete.play()
	final_musica.play()

	# Liga animação dos motores
	anim.play("decolar")

	# Vibra por 10 segundos
	vibrando = true
	await get_tree().create_timer(TEMPO_VIBRACAO).timeout

	vibrando = false
	position = posicao_original

	# Decola
	subindo = true
	await get_tree().create_timer(TEMPO_SUBIDA).timeout

	# Para os sons da nave
	som_foguete.stop()
	final_musica.stop()

	# Tela final
	get_tree().current_scene.get_node("ColorRect/PixelFade").trocar_fase("res://Cenas/final.tscn")
