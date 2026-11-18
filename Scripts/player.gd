class_name CosmosPlayer
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
@export_range(1.0, 3000.0) var aceleracao: float = 900.0
@export_range(1.0, 3000.0) var desaceleracao: float = 1200.0

@export_category("Dano")
@export_range(0.01, 2.0) var tempo_protecao_dano: float = 0.25
@export_range(0.01, 2.0) var tempo_knockback: float = 0.14


# === CONFIGURAÇÕES DE MORTE ===
@export_category("Morte")
@export var impulso_morte: float = -300.0
@export var tempo_ate_game_over: float = 1.5
@export var limite_queda: float = 1000.0


# === CONFIGURAÇÕES DE OXIGÊNIO ===
@export_category("Oxigênio")
@export_range(1, 1000) var oxigenio_maximo: int = 100
@export_range(0, 1000) var perda_por_intervalo: int = 1
@export_range(0.05, 10.0) var intervalo_consumo: float = 0.25
@export_range(1, 1000) var recuperacao_capsula: int = 20


# === ESTADO DO PLAYER ===
var oxigenio_atual: int = 100
var ja_morreu: bool = false
var saindo_da_fase: bool = false
var protecao_dano_restante: float = 0.0
var knockback_restante: float = 0.0


# === NÓS ===
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var barra_oxigenio: ProgressBar = $CanvasLayer/ProgressBar
@onready var oxygen_bar: AnimatedSprite2D = $CanvasLayer/OxygenBar
@onready var label_oxigenio: Label = $CanvasLayer/LabelOxigenio
@onready var timer_oxigenio: Timer = $Timer
@onready var cristais_hud: AnimatedSprite2D = $CanvasLayer/CristaisHUD


func _ready() -> void:
	timer_oxigenio.wait_time = intervalo_consumo
	timer_oxigenio.one_shot = false

	if not timer_oxigenio.timeout.is_connected(_on_timer_timeout):
		timer_oxigenio.timeout.connect(_on_timer_timeout)

	if perda_por_intervalo > 0:
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
	if protecao_dano_restante > 0.0:
		protecao_dano_restante = maxf(protecao_dano_restante - delta, 0.0)
		if protecao_dano_restante == 0.0:
			anim.modulate = Color.WHITE

	if knockback_restante > 0.0:
		knockback_restante = maxf(knockback_restante - delta, 0.0)
	else:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_force

		var direcao := Input.get_axis("ui_left", "ui_right")
		var taxa := aceleracao if direcao != 0.0 else desaceleracao
		velocity.x = move_toward(velocity.x, direcao * speed, taxa * delta)
		if direcao != 0.0:
			anim.flip_h = direcao < 0.0

	move_and_slide()
	atualizar_animacao()

	# === MORTE POR QUEDA ===
	if global_position.y > limite_queda:
		game_over()


# =========================================================
# ANIMAÇÕES
# =========================================================

func atualizar_animacao() -> void:
	var anim_name := "idle"

	if not is_on_floor():
		if velocity.y < 0:
			anim_name = "jump"
		else:
			anim_name = "fall"

	elif absf(get_real_velocity().x) > 1.0:
		anim_name = "run"

	if anim.animation != anim_name:
		anim.play(anim_name)


# =========================================================
# OXIGÊNIO
# =========================================================

func _on_timer_timeout() -> void:
	if not pode_interagir():
		return

	oxigenio_atual -= perda_por_intervalo
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


func recuperar_oxigenio() -> bool:
	if not pode_interagir():
		return false

	oxigenio_atual = mini(oxigenio_atual + recuperacao_capsula, oxigenio_maximo)
	atualizar_ui_oxigenio()
	return true


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

func receber_dano(quantidade: int, origem: Vector2) -> void:
	if not pode_interagir() or protecao_dano_restante > 0.0 or quantidade <= 0:
		return

	oxigenio_atual = maxi(oxigenio_atual - quantidade, 0)
	atualizar_ui_oxigenio()

	if oxigenio_atual == 0:
		game_over()
		return

	protecao_dano_restante = tempo_protecao_dano
	knockback_restante = tempo_knockback
	var direcao_knockback := signf(global_position.x - origem.x)
	if direcao_knockback == 0.0:
		direcao_knockback = 1.0 if anim.flip_h else -1.0

	velocity = Vector2(direcao_knockback * 180.0, -140.0)
	anim.modulate = Color(1.0, 0.25, 0.25)


func pode_interagir() -> bool:
	return not ja_morreu and not saindo_da_fase


func preparar_saida(esconder: bool = false) -> bool:
	if not pode_interagir():
		return false

	saindo_da_fase = true
	visible = not esconder
	timer_oxigenio.paused = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	return true


func concluir_saida(destino: String) -> bool:
	if await TransicaoGlobal.get_node("PixelFade").trocar_fase(destino):
		return true

	# Recupera os controles se a troca de cena falhar.
	saindo_da_fase = false
	visible = true
	timer_oxigenio.paused = false
	set_physics_process(true)
	return false


# =========================================================
# GAME OVER
# =========================================================

func game_over() -> void:
	if ja_morreu:
		return

	ja_morreu = true

	timer_oxigenio.stop()

	# === DESATIVA COLISÕES ===
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)

	# === MOVIMENTO DE MORTE ===
	velocity.x = 0.0
	velocity.y = impulso_morte

	anim.play("jump")

	await get_tree().create_timer(
		tempo_ate_game_over, false
	).timeout

	get_tree().change_scene_to_file(
		"res://Cenas/game_over.tscn"
	)
