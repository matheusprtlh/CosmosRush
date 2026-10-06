extends Label

@export var tempo_fade_in: float = 0.5
@export var tempo_visivel: float = 1.5
@export var tempo_fade_out: float = 0.5

var textos: Array[String] = [
	"CONTROLES\nA / D — Movimentar\nW ou ESPAÇO — Pular\nESC — Pausar o jogo",

	"SUA MISSÃO\nAtravesse os planetas\nem busca dos 4 cristais.\nEncontre todos eles\npara concluir sua missão.",

	"OXIGÊNIO\nFique de olho na sua\nbarra de oxigênio!\nSe ela chegar a zero,\né Game Over.\nColete cápsulas para\nrecuperar oxigênio.",

	"PERIGOS\nCuidado com os inimigos\ne com as quedas!\nAo encostar em um inimigo,\nvocê perde oxigênio\ne sofre knockback.",

	"GRAVIDADE\nCada planeta possui\numa gravidade diferente.\nSeus movimentos e saltos\nmudarão durante a jornada.",

	"CRISTAIS\nExistem 4 cristais\nespalhados pelos planetas.\nO indicador mostra quantos\nvocê já encontrou.\nEncontre todos eles!",

	"EXPLORE. SOBREVIVA.\nENCONTRE OS CRISTAIS.\nSua jornada está apenas\ncomeçando...\nBoa viagem, astronauta!"
]

func _ready() -> void:
	modulate.a = 0.0
	rodar_tutorial()

func rodar_tutorial() -> void:
	for mensagem in textos:
		text = mensagem

		var fade_in := create_tween()
		fade_in.tween_property(self, "modulate:a", 1.0, tempo_fade_in)
		await fade_in.finished

		await get_tree().create_timer(tempo_visivel).timeout

		var fade_out := create_tween()
		fade_out.tween_property(self, "modulate:a", 0.0, tempo_fade_out)
		await fade_out.finished

	get_tree().change_scene_to_file("res://Cenas/terra_1.tscn")
