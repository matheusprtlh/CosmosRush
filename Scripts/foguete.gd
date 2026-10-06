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
	if ativado:
		return

	if body is CharacterBody2D:
		ativado = true

		# Faz o player desaparecer
		body.visible = false
		body.set_physics_process(false)

		# Desativa a colisão do foguete
		$CollisionShape2D.set_deferred("disabled", true)

		# Toca o foguete
		som_foguete.play()

		# Começa a tremer
		tremendo = true

		# Fica tremendo por 5 segundos
		await get_tree().create_timer(tempo_tremendo).timeout

		# Para o tremor
		tremendo = false
		position = posicao_original

		# Começa a subir
		subindo = true

		# Sobe durante 3 segundos
		await get_tree().create_timer(tempo_subida).timeout

		# Vai para Marte
		get_tree().current_scene.get_node("ColorRect/PixelFade").trocar_fase("res://Cenas/marte.tscn")
