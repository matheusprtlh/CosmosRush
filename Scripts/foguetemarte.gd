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
	if ativado:
		return

	if body is CharacterBody2D:
		ativado = true

		# Player desaparece
		body.visible = false
		body.set_physics_process(false)

		# Desativa colisão do foguete
		$CollisionShape2D.set_deferred("disabled", true)

		# Toca o som
		som_foguete.play()

		# Vibração
		vibrando = true
		await get_tree().create_timer(TEMPO_VIBRACAO).timeout

		vibrando = false
		position = posicao_original

		# Decolagem
		subindo = true
		await get_tree().create_timer(TEMPO_SUBIDA).timeout

		# Lua
		get_tree().current_scene.get_node("ColorRect/PixelFade").trocar_fase("res://Cenas/lua.tscn")
