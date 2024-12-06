extends Control

@onready var dinheiro: RichTextLabel = $DINHEIRO
var previous_value = 0
var is_animating = false

@onready var revert_timer: Timer = $DINHEIRO/revert_timer


@onready var nome_label: RichTextLabel = $Label

@onready var damage_numb: RichTextLabel = $hbox/VBoxContainer/Damage/numb
@onready var proje_numb: RichTextLabel = $hbox/VBoxContainer/Proje/numb
@onready var reload_numb: RichTextLabel = $hbox/VBoxContainer/Reload/numb
@onready var taxadetiro_numb: RichTextLabel = $hbox/VBoxContainer2/taxadetiro/numb
@onready var municaomaxima_numb: RichTextLabel = $hbox/VBoxContainer2/municaomaxima/numb

@onready var preco_numb: RichTextLabel = $hbox/VBoxContainer/preco/numb




func _ready():
	previous_value = Global.pontos
	dinheiro.bbcode_text = "$ {0}".format([Global.pontos])


func _physics_process(delta: float) -> void:
	match Global.weapon_data:
		"Magnun":
			update_weapon_stats("Magnun") 
		"MP7":
			update_weapon_stats("MP7") 

	
	
	if Global.pontos != previous_value and not is_animating:
		# Se o valor mudou e não está animando, aplica o efeito
		is_animating = true
		dinheiro.bbcode_text = "$ [color=red][shake rate=10 level=20]{0}[/shake][/color]".format([Global.pontos])
		revert_timer.start(1) # Mantém o efeito por 2 segundos
		previous_value = Global.pontos

func _on_revert_timeout():
	# Reverte o texto para o estado normal
	dinheiro.bbcode_text = "$ {0}".format([Global.pontos])
	is_animating = false


func update_weapon_stats(weapon_name: String):
	# Atualiza os textos com base no weapon_data
	var data = Global.guns_weapon_data.get(weapon_name)
	if data:
		preco_numb.text = str("$", data.preco)
		damage_numb.text = str(data.dano)
		proje_numb.text = str(data.projeteis)
		reload_numb.text = str(data.tempo_recarga)
		taxadetiro_numb.text = str(data.taxa_tiro)
		municaomaxima_numb.text = str(data.municao_maxima)
		nome_label.text = weapon_name  # Define o nome da arma como o texto de nome_label
