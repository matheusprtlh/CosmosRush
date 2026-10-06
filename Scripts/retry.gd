extends RichTextLabel

@onready var botao: Button = $ButtonRetry

func _ready():
	botao.mouse_entered.connect(_mouse_entrou)
	botao.mouse_exited.connect(_mouse_saiu)

func _mouse_entrou():
	text = "[shake rate=20 level=5]Retry[/shake]"

func _mouse_saiu():
	text = "Retry"
