extends Node2D

@onready var player: CosmosPlayer = $Player


func _ready() -> void:
	player.timer_oxigenio.stop()
