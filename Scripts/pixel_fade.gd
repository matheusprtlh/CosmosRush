extends ColorRect

@export var duracao_entrada: float = 1.0
@export var tempo_preenchido: float = 0.5
@export var duracao_saida: float = 1.0

@onready var shader_material: ShaderMaterial = material as ShaderMaterial
var trocando_fase: bool = false
var revelacao_direta: Tween


func _ready() -> void:
	_set_progress(2.0)
	get_tree().scene_changed.connect(_on_scene_changed)


func trocar_fase(caminho_da_fase: String) -> bool:
	if trocando_fase:
		return false
	if not ResourceLoader.exists(caminho_da_fase, "PackedScene"):
		push_error("Fase de destino inválida: " + caminho_da_fase)
		return false

	trocando_fase = true
	if revelacao_direta and revelacao_direta.is_valid():
		revelacao_direta.kill()

	var progresso := float(shader_material.get_shader_parameter("progress"))
	await _animar_progress(progresso, 1.0, duracao_entrada).finished

	var erro := get_tree().change_scene_to_file(caminho_da_fase)
	if erro == OK:
		await get_tree().scene_changed
	else:
		push_error("Não foi possível abrir a fase: " + caminho_da_fase)

	await _animar_progress(1.0, 2.0, duracao_saida, tempo_preenchido).finished
	trocando_fase = false
	return erro == OK


func _on_scene_changed(nova_cena: Node) -> void:
	# Em trocas diretas, como reiniciar, apenas a revelação é necessária.
	if trocando_fase:
		return
	if revelacao_direta and revelacao_direta.is_valid():
		revelacao_direta.kill()
	_set_progress(2.0)

	var caminho := nova_cena.scene_file_path
	if caminho.begins_with("res://Cenas/terra_") or caminho.begins_with("res://Cenas/marte") or caminho.begins_with("res://Cenas/lua"):
		_set_progress(1.0)
		revelacao_direta = _animar_progress(1.0, 2.0, duracao_saida, tempo_preenchido)


func _animar_progress(inicio: float, fim: float, duracao: float, espera: float = 0.0) -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if espera > 0.0:
		tween.tween_interval(espera)
	tween.tween_method(_set_progress, inicio, fim, duracao)
	return tween


func _set_progress(valor: float) -> void:
	shader_material.set_shader_parameter("progress", valor)
