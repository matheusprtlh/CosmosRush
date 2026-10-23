extends Node2D

@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	player.oxigenio_maximo = 99999999
	player.oxigenio_atual = 99999999
