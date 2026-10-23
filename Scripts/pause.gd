extends Control

# Uma unica instancia deste menu permanece ativa atraves do Autoload GlobalPause.
# Todas as fases usam o mesmo ESC (ui_cancel) e o mesmo menu visual.
const CENAS_SEM_PAUSE = [
    "res://Cenas/menu.tscn",
    "res://Cenas/game_over.tscn",
    "res://Cenas/final.tscn",
    "res://Cenas/loading.tscn"
]

@onready var som_click: AudioStreamPlayer = $SomClick

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    som_click.process_mode = Node.PROCESS_MODE_ALWAYS
    hide()
    get_tree().scene_changed.connect(_on_scene_changed)


func _input(event: InputEvent) -> void:
    if not event.is_action_pressed("ui_cancel") or event.is_echo():
        return

    var cena_atual: Node = get_tree().current_scene
    if cena_atual == null or cena_atual.scene_file_path in CENAS_SEM_PAUSE:
        return

    if get_tree().paused:
        continuar_jogo()
    else:
        pausar_jogo()

    get_viewport().set_input_as_handled()


func _on_scene_changed(_nova_cena: Node) -> void:
    # Um Pause global nao pode ficar aberto ao entrar numa nova cena.
    continuar_jogo()


func tocar_click() -> void:
    som_click.play()
    await get_tree().create_timer(0.08, true).timeout


func pausar_jogo() -> void:
    show()
    get_tree().paused = true


func continuar_jogo() -> void:
    get_tree().paused = false
    hide()


func _on_menu_pressed() -> void:
    await tocar_click()
    continuar_jogo()
    get_tree().change_scene_to_file("res://Cenas/menu.tscn")


func _on_continue_pressed() -> void:
    await tocar_click()
    continuar_jogo()


func _on_restart_pressed() -> void:
    await tocar_click()
    continuar_jogo()
    get_tree().reload_current_scene()
