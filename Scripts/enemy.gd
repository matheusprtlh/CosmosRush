extends CharacterBody2D

@export var velocidade: float = 50.0
@export var gravidade: float = 800.0
@export var dano: int = 15

# 1 = direita; -1 = esquerda
var dir: int = 1

@onready var wall_check: RayCast2D = $WallCheck
@onready var floor_check: RayCast2D = $FloorCheck


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravidade * delta

	# Atualiza os sensores antes de decidir o movimento.
	wall_check.force_raycast_update()
	floor_check.force_raycast_update()

	if is_on_floor() and (wall_check.is_colliding() or not floor_check.is_colliding()):
		inverter_direcao()

	velocity.x = dir * velocidade
	move_and_slide()


func inverter_direcao() -> void:
	dir *= -1
	# Espelha sprite e sensores, preservando o comportamento original.
	scale.x *= -1


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("receber_dano"):
		body.receber_dano(dano, global_position)
