extends RichTextLabel

@onready var botao: Button = $ButtonMenu

func _ready():
	botao.mouse_entered.connect(_mouse_entrou)
	botao.mouse_exited.connect(_mouse_saiu)

func _mouse_entrou():
	text = "[shake rate=20 level=5]menu[/shake]"

func _mouse_saiu():
	text = "menu"
