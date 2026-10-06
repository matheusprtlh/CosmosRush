extends Button

@onready var texto_play: RichTextLabel = get_parent()

func _ready():
	mouse_entered.connect(_mouse_entrou)
	mouse_exited.connect(_mouse_saiu)

func _mouse_entrou():
	texto_play.text = "[shake rate=20.0 level=5 connected=1]play[/shake]"

func _mouse_saiu():
	texto_play.text = "play"
