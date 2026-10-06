extends CharacterBody2D

# =========================================================
# PLAYER UNIVERSAL - COSMOS RUSH
# Usado na Terra, Marte e Lua.
# Os valores de cada planeta são configurados pelo Inspector.
# =========================================================


# === CONFIGURAÇÕES DE MOVIMENTO ===
@export_category("Movimento")
@export var speed: float = 110.0
@export var jump_force: float = -290.0
@export var gravity: float = 800.0


# === CONFIGURAÇÕES DE MORTE ===
@export_category("Morte")
@export var impulso_morte: float = -300.0
@export var tempo_ate_game_over: float = 1.5
@export var limite_queda: float = 1000.0


# === CONFIGURAÇÕES DE OXIGÊNIO ===
@export_category("Oxigênio")
@export var oxigenio_maximo: int = 100
@export var perda_por_segundo: int = 1
@export var recuperacao_capsula: int = 20


# === ESTADO DO PLAYER ===
var oxigenio_atual: int = 100
var tem_nucleo: bool = false
var ja_morreu: bool = false


# === NÓS ===
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var barra_oxigenio: ProgressBar = $CanvasLayer/ProgressBar
@onready var oxygen_bar: AnimatedSprite2D = $CanvasLayer/OxygenBar
@onready var label_oxigenio: Label = $CanvasLayer/LabelOxigenio
@onready var timer_oxigenio: Timer = $Timer
@onready var cristais_hud: AnimatedSprite2D = $CanvasLayer/CristaisHUD


func _ready() -> void:
	timer_oxigenio.wait_time = 0.25
	timer_oxigenio.one_shot = false

	if not timer_oxigenio.timeout.is_connected(_on_timer_timeout):
		timer_oxigenio.timeout.connect(_on_timer_timeout)

	timer_oxigenio.start()

	oxigenio_atual = oxigenio_maximo

	atualizar_ui_oxigenio()
	atualizar_hud_cristais()


func _physics_process(delta: float) -> void:
	# === MORTE ===
	if ja_morreu:
		velocity.y += gravity * delta
		move_and_slide()
		return

	# === GRAVIDADE ===
	if not is_on_floor():
		velocity.y += gravity * delta

	# === PULO ===
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	# === MOVIMENTO HORIZONTAL ===
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * speed
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			speed
		)

	move_and_slide()

	atualizar_animacao(direction)

	# === MORTE POR QUEDA ===
	if global_position.y > limite_queda:
		game_over()


# =========================================================
# ANIMAÇÕES
# =========================================================

func atualizar_animacao(direction: float) -> void:
	var anim_name := "idle"

	if not is_on_floor():
		if velocity.y < 0:
			anim_name = "jump"
		else:
			anim_name = "fall"

	elif direction != 0:
		anim_name = "run"

	if anim.animation != anim_name:
		anim.play(anim_name)


# =========================================================
# OXIGÊNIO
# =========================================================

func _on_timer_timeout() -> void:
	if ja_morreu:
		return

	oxigenio_atual -= perda_por_segundo
	oxigenio_atual = max(oxigenio_atual, 0)

	atualizar_ui_oxigenio()

	if oxigenio_atual <= 0:
		game_over()


func atualizar_ui_oxigenio() -> void:
	if barra_oxigenio:
		barra_oxigenio.max_value = oxigenio_maximo
		barra_oxigenio.value = oxigenio_atual

	if label_oxigenio:
		label_oxigenio.text = (
			str(oxigenio_atual)
			+ "/"
			+ str(oxigenio_maximo)
		)

	if oxygen_bar:
		var porcentagem := (
			float(oxigenio_atual)
			/ float(oxigenio_maximo)
		)

		var frame_oxigenio := int(
			round((1.0 - porcentagem) * 15.0)
		)

		oxygen_bar.frame = clamp(
			frame_oxigenio,
			0,
			15
		)


func recuperar_oxigenio(
	quantidade: int = recuperacao_capsula
) -> void:

	if ja_morreu:
		return

	oxigenio_atual = min(
		oxigenio_atual + quantidade,
		oxigenio_maximo
	)

	atualizar_ui_oxigenio()


func _on_capsula_body_entered(body: Node) -> void:
	if body == self:
		recuperar_oxigenio()


# =========================================================
# CRISTAIS
# =========================================================

func atualizar_hud_cristais() -> void:
	if cristais_hud:
		cristais_hud.frame = clamp(
			Gamedata.cristais,
			0,
			4
		)


# =========================================================
# DANO
# =========================================================

func receber_dano(
	quantidade: int,
	origem: Vector2
) -> void:

	if ja_morreu:
		return

	oxigenio_atual = max(
		oxigenio_atual - quantidade,
		0
	)

	atualizar_ui_oxigenio()

	if oxigenio_atual <= 0:
		game_over()
		return

	# === KNOCKBACK ===
	var direcao_knockback: float = signf(
		global_position.x - origem.x
	)

	if direcao_knockback == 0.0:
		direcao_knockback = 1.0

	velocity.x = direcao_knockback * 180.0
	velocity.y = -140.0

	# === FEEDBACK VISUAL DE DANO ===
	anim.modulate = Color(
		1.0,
		0.25,
		0.25
	)

	await get_tree().create_timer(0.2).timeout

	if is_instance_valid(anim) and not ja_morreu:
		anim.modulate = Color.WHITE


# =========================================================
# GAME OVER
# =========================================================

func game_over() -> void:
	if ja_morreu:
		return

	ja_morreu = true

	timer_oxigenio.stop()

	# === DESATIVA COLISÕES ===
	collision_layer = 0
	collision_mask = 0

	# === MOVIMENTO DE MORTE ===
	velocity.x = 0.0
	velocity.y = impulso_morte

	anim.play("jump")

	await get_tree().create_timer(
		tempo_ate_game_over
	).timeout

	get_tree().change_scene_to_file(
		"res://Cenas/game_over.tscn"
	)
