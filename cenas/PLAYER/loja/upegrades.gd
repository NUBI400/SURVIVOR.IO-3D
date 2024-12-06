extends Control

@onready var maxvida_numb: RichTextLabel = $scrollcontainer/VBoxContainer/Maxvida/numb
@onready var recu_vida_numb: RichTextLabel = $scrollcontainer/VBoxContainer/RecuVida/numb
@onready var velocit_numb: RichTextLabel = $scrollcontainer/VBoxContainer/Velocit/numb

@export var UI : CanvasLayer 


func _ready() -> void:
	maxvida_numb.text = str(Global.preço_aumentar_vida)
	velocit_numb.text = str(Global.preço_aumentar_velocidade)



func atualizar_preço_aumentar_vida(novo_preço: int) -> void:
	Global.preço_aumentar_vida = novo_preço
	maxvida_numb.text = str(Global.preço_aumentar_vida)
	UI.uptate_ui_player_loja()

func atualizar_preço_aumentar_velocidade(novo_preço: int) -> void:
	Global.preço_aumentar_velocidade = novo_preço
	velocit_numb.text = str(Global.preço_aumentar_velocidade)


func _on_comprar_buff(_buff_name) -> void:
	match _buff_name:
		"vidamax":
			atualizar_preço_aumentar_vida(Global.preço_aumentar_vida * 1.1)
			Global.health_player += Global.health_player_buff
		"velocidade":
			atualizar_preço_aumentar_velocidade(Global.preço_aumentar_velocidade * 1.1)
			Global.walking_speed += Global.walking_speed_buff
