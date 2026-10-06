extends Control

@onready var som_tambor: AudioStreamPlayer = $SomTambor
@onready var space_sound: AudioStreamPlayer = $SpaceSound
@onready var obrigado: Label = $Obrigado

func _ready() -> void:
	# Garante que o Master não esteja mutado
	var master_index: int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_index, false)

	# Texto começa escondido
	obrigado.hide()

	# Impacto ao cortar para preto
	som_tambor.play()

	# Tela preta por 3 segundos
	await get_tree().create_timer(3.0).timeout

	# Começa o SpaceSound
	space_sound.play()

	# Música toca por 10 segundos
	await get_tree().create_timer(8.0).timeout

	# Mostra mensagem
	obrigado.show()

	# Mensagem permanece por 5 segundos
	await get_tree().create_timer(3.0).timeout

	# Para o som
	space_sound.stop()

	# Reseta a partida
	Gamedata.resetar_jogo()

	# Volta ao menu
	get_tree().change_scene_to_file("res://Cenas/menu.tscn")
