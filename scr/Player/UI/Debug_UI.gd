extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var tempo: RichTextLabel = $"../Tempo"
@onready var debug_hud: Control = $"."

func _physics_process(delta: float) -> void:	
	if Global.loja_aberta == true:
		Global.loja_aberta = null
		animation_player.play("fade")
	
	if Global.loja_aberta == false:
		Global.loja_aberta = null
		animation_player.play_backwards("fade")
