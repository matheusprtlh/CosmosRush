extends Node

var cristais: int:
	get:
		return cristais_coletados.size()

var cristais_coletados: Dictionary[String, bool] = {}


func cristal_coletado(tipo: String) -> bool:
	return cristais_coletados.has(tipo)


func coletar_cristal(tipo: String) -> void:
	cristais_coletados[tipo] = true


func resetar_jogo() -> void:
	cristais_coletados.clear()
