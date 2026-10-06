extends CharacterBody2D

var dir: int = 1
var velocidade: float = 50.0
var dano: int = 15

func _physics_process(_delta: float) -> void:
	velocity.x = dir * velocidade
	move_and_slide()

	if $WallCheck.is_colliding():
		dir *= -1
		scale.x *= -1

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("ENCOSTOU EM: ", body.name)

	if body.has_method("receber_dano"):
		print("PLAYER DETECTADO!")
		body.receber_dano(dano, global_position)
