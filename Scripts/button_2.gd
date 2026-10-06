extends Button

@onready var texto_quit: RichTextLabel = get_parent()

func _ready():
	mouse_entered.connect(_mouse_entrou)
	mouse_exited.connect(_mouse_saiu)

func _mouse_entrou():
	texto_quit.text = "[shake rate=20.0 level=5 connected=1]quit[/shake]"

func _mouse_saiu():
	texto_quit.text = "quit"
