extends Node

var gravity_padrao = 16
var gravity_submersoAGUA = 4
var gravity = gravity_padrao

var sair_do_celular = false


var Round = 0
var tempo_round = 0
var InimigosRound = 0
var ContagemInimigos = 1




var Player_Pos = null


var pontos = 0
var preço_mp7 = 50
var preço_revolver = 30
var preço_shotgun = 70
var preço_medkit = 20


var preço_aumentar_vida = 50
var preço_aumentar_velocidade = 20
var preço_aumentar_recuperar_vida = 20



var revolver_possui = false
var mp7_possui = false

var weapon_data = null

var owned_weapons = []

func is_weapon_owned(weapon_name: String) -> bool:
	return weapon_name in owned_weapons

func mark_weapon_as_owned(weapon_name: String) -> void:
	# Verifica se já existe uma arma na lista
	if owned_weapons.size() >= 1:
		# Se sim, zera a array
		owned_weapons.clear()

	# Adiciona a nova arma à lista
	if not is_weapon_owned(weapon_name):
		owned_weapons.append(weapon_name)


var health_player = 40
var health_player_buff = 10

var walking_speed = 40.0
var walking_speed_buff = 10




var preço_mp7_visivel = false
var preço_shotgun_visivel = false
var preço_revolver_visivel = false
var preço_medkit_visivel = false


var zumbis_locais_ruins = 0


var loja_aberta = false

var criacao_no_pai = null

func instantiate_node(node, location, parent):
	var node_instantiate = node.instantiate()
	parent.add_child(node_instantiate)
	node_instantiate.global_position = location
	return node_instantiate


var inimigos_ativos: int = 0
var max_inimigos_ativos: int = 30 



var guns_weapon_data = {
	"Magnun": {
		"preco": 50,
		"dano": 20,
		"projeteis": 1,
		"tempo_recarga": 0.8, # segundos
		"taxa_tiro": 2.5, # tiros por segundo
		"municao_maxima": 6
	},
	"MP7": {
		"preco": 60,
		"dano": 20,
		"projeteis": 1,
		"tempo_recarga": 1.6, # segundos
		"taxa_tiro": 10, # tiros por segundo
		"municao_maxima": 30
	}
}
