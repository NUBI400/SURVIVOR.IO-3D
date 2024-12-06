extends StaticBody3D

var ativando = false
var ativar = 6.0  # Tempo em segundos que o jogador deve permanecer na área
var ativar_max = 6.0  # Tempo em segundos que o jogador deve permanecer na área

@onready var loja_ui: Control = $Loja_visual/LOJA_UI
@onready var mesh: MeshInstance3D = $Mesh
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_activate_area_area_entered(area):
	if area.is_in_group("Player"):
		ativando = true  # Inicia o contador quando o jogador entra na área
		animation_player.play("aumentar")

func _on_activate_area_area_exited(area):
	if area.is_in_group("Player"):
		ativando = false  # Para o contador se o jogador sair da área
		ativar = ativar_max  # Reseta o contador para o valor inicial
		animation_player.stop()
		animation_player.play("RESET")



func _physics_process(delta):
	if ativando:
		ativar -= delta  # Diminui o tempo restante
		if ativar <= 0:
			ativando = false
			loja_ui.paused()  # Pausa a loja UI quando o tempo chegar a zero
			animation_player.stop()
			animation_player.play("RESET")
