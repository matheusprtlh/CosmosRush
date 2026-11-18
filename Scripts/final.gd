extends Control

@export_range(0.1, 30.0) var tempo_impacto: float = 3.0
@export_range(0.1, 30.0) var tempo_ate_mensagem: float = 8.0
@export_range(0.1, 30.0) var tempo_mensagem: float = 5.0

@onready var som_tambor: AudioStreamPlayer = $SomTambor
@onready var space_sound: AudioStreamPlayer = $SpaceSound
@onready var obrigado: Label = $Obrigado


func _ready() -> void:
	som_tambor.play()
	await get_tree().create_timer(tempo_impacto, false).timeout

	space_sound.play()
	await get_tree().create_timer(tempo_ate_mensagem, false).timeout

	obrigado.show()
	await get_tree().create_timer(tempo_mensagem, false).timeout

	Gamedata.resetar_jogo()
	get_tree().change_scene_to_file("res://Cenas/menu.tscn")
