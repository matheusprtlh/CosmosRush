extends CharacterBody2D

@export var velocidade: float = 50.0
@export var gravidade: float = 800.0
@export var dano: int = 15

var direcao: int = 1

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_check: RayCast2D = $WallCheck
@onready var floor_check: RayCast2D = $FloorCheck
@onready var alcance_parede: float = absf(wall_check.target_position.x)
@onready var distancia_borda: float = absf(floor_check.position.x)


func _physics_process(delta: float) -> void:
	velocity.x = direcao * velocidade

	if is_on_floor():
		if not caminho_livre(direcao):
			if caminho_livre(-direcao):
				direcao = -direcao
				anim.flip_h = direcao < 0
				velocity.x = direcao * velocidade
			else:
				velocity.x = 0.0
	else:
		velocity.y += gravidade * delta

	move_and_slide()


func caminho_livre(lado: int) -> bool:
	wall_check.target_position.x = alcance_parede * lado
	floor_check.position.x = distancia_borda * lado
	wall_check.force_raycast_update()
	floor_check.force_raycast_update()
	return not wall_check.is_colliding() and floor_check.is_colliding()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CosmosPlayer:
		body.receber_dano(dano, global_position)
