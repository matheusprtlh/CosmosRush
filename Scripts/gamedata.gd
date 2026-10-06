extends Node

var cristais: int = 0
var tem_nucleo: bool = false

func coletar_cristal() -> void:
	if cristais < 4:
		cristais += 1
		print("Cristais: ", cristais, "/4")

func resetar_jogo() -> void:
	cristais = 0
	tem_nucleo = false
