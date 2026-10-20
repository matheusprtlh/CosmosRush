extends ColorRect

# Transição persistente: o CanvasLayer permanece na árvore ao trocar a fase.
@export var duracao_entrada: float = 1.0
@export var tempo_preenchido: float = 0.5
@export var duracao_saida: float = 1.0

@onready var shader_material: ShaderMaterial = material as ShaderMaterial
var trocando_fase: bool = false
var revelando: bool = false

func _ready() -> void:
    # O menu inicial não precisa começar coberto.
    shader_material.set_shader_parameter("progress", 2.0)
    get_tree().scene_changed.connect(_on_scene_changed)

func trocar_fase(caminho_da_fase: String) -> void:
    if trocando_fase or caminho_da_fase.is_empty():
        return
    trocando_fase = true
    # Se a entrada da fase ainda estiver revelando, interrompe o tween.
    for tween in get_tree().get_processed_tweens():
        if tween.is_valid() and tween.is_running() and tween.has_meta("cosmos_fade"):
            tween.kill()
    revelando = false
    await _animar_progress(float(shader_material.get_shader_parameter("progress")), 1.0, duracao_entrada)
    # A cobertura fica visível inclusive no frame em que a cena é removida.
    shader_material.set_shader_parameter("progress", 1.0)
    var erro := get_tree().change_scene_to_file(caminho_da_fase)
    if erro != OK:
        push_error("Não foi possível abrir a fase: " + caminho_da_fase)
        await _revelar()
        trocando_fase = false
        return
    # Aguarda a nova cena estar montada atrás do CanvasLayer global.
    await get_tree().scene_changed
    await _revelar()
    trocando_fase = false

func _on_scene_changed(nova_cena: Node) -> void:
    # Para trocas diretas (menu, retry), a nova fase também ganha fade de entrada.
    if trocando_fase or revelando:
        return
    if nova_cena.scene_file_path.begins_with("res://Cenas/terra_") or nova_cena.scene_file_path.begins_with("res://Cenas/marte") or nova_cena.scene_file_path.begins_with("res://Cenas/lua"):
        shader_material.set_shader_parameter("progress", 1.0)
        _revelar()

func _revelar() -> void:
    if revelando:
        return
    revelando = true
    await get_tree().create_timer(tempo_preenchido).timeout
    await _animar_progress(1.0, 2.0, duracao_saida)
    revelando = false

func _animar_progress(inicio: float, fim: float, duracao: float) -> void:
    var tween := create_tween()
    tween.set_meta("cosmos_fade", true)
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.tween_method(_set_progress, inicio, fim, duracao)
    await tween.finished

func _set_progress(valor: float) -> void:
    shader_material.set_shader_parameter("progress", valor)
