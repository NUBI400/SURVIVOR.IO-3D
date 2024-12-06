extends Button

signal buff

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var _buff_name: String

var preço = null

func _ready():
	match _buff_name:
		"vidamax":
			preço = Global.preço_aumentar_vida
		"velocidade":
			preço = Global.preço_aumentar_velocidade
	

func _on_button_down() -> void:
	if preço <= Global.pontos:
		Global.pontos -= preço
		open()
	else:
		_not_open()


func open():
	emit_signal("buff", _buff_name)


func _not_open():
	animation_player.play("nao")
