extends Control

const CENAS_SEM_PAUSE = [
	"res://Cenas/menu.tscn",
	"res://Cenas/game_over.tscn",
	"res://Cenas/final.tscn",
	"res://Cenas/loading.tscn"
]

@onready var som_click: AudioStreamPlayer = $SomClick
@onready var pixel_fade = TransicaoGlobal.get_node("PixelFade")
@onready var botao_continuar: TextureButton = $CaixaPause/Continue

var acao_em_andamento: bool = false


func _ready() -> void:
	hide()
	get_tree().scene_changed.connect(_on_scene_changed)


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or event.is_echo():
		return

	var cena_atual := get_tree().current_scene
	if acao_em_andamento or pixel_fade.trocando_fase:
		return
	if cena_atual == null or cena_atual.scene_file_path in CENAS_SEM_PAUSE:
		return

	if get_tree().paused:
		continuar_jogo()
	else:
		pausar_jogo()

	get_viewport().set_input_as_handled()


func _on_scene_changed(_nova_cena: Node) -> void:
	continuar_jogo()


func pausar_jogo() -> void:
	get_tree().paused = true
	show()
	botao_continuar.grab_focus()


func continuar_jogo() -> void:
	hide()
	get_tree().paused = false
	acao_em_andamento = false


func executar_acao(destino: String = "", reiniciar: bool = false) -> void:
	if acao_em_andamento or not visible:
		return

	acao_em_andamento = true
	var cena_atual := get_tree().current_scene
	som_click.play()
	await get_tree().create_timer(0.08).timeout
	if get_tree().current_scene != cena_atual:
		return

	continuar_jogo()
	if reiniciar:
		get_tree().reload_current_scene()
	elif not destino.is_empty():
		Gamedata.resetar_jogo()
		get_tree().change_scene_to_file(destino)


func _on_menu_pressed() -> void:
	executar_acao("res://Cenas/menu.tscn")


func _on_continue_pressed() -> void:
	executar_acao()


func _on_restart_pressed() -> void:
	executar_acao("", true)
