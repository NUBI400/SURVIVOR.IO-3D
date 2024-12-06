extends Node3D
@onready var sol: DirectionalLight3D = $Visual/DirectionalLight3D

var velocidade_rotacao: float = 0.005



@onready var camera: Camera3D = $Player/camera
@onready var timer_spawn_inimigo: Timer = $Timer_spawn_inimigo
@onready var timer_dificuldade: Timer = $Timer_dificuldade
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var inimigo_1 = preload("res://cenas/Inimigos/Inimigo_padrao.tscn")
const INIMIGO_TANK = preload("res://cenas/Inimigos/Inimigo_tank.tscn")

const MAGNUN = preload("res://assets/Modelos/revolver/Magnun.glb")
const REVOLVER_BALA = preload("res://assets/Modelos/revolver/revolver_bala.glb")

const MP_7 = preload("res://assets/Modelos/MP7/MP7.glb")

const LIGHT_ASSAULT_MECH = preload("res://assets/Modelos/ROBO/light_assault_mech.glb")


const PASSOROBOFODASE = preload("res://assets/sounds/passorobofodase.mp3")
const SOM_DO_ESPA_O_SELOKO = preload("res://assets/sounds/som do espaço seloko.mp3")


@export var inimigos: Array[PackedScene]
@export var probabilidades: Array[float]  # Probabilidade para cada inimigo, soma deve ser 1.0
@export var spawn_margin: float = 0.0  
@export var quantidade_inimigos_por_spawn: int = 1 

var tempo_total: float = 10 * 60  
var tempo_passado: float = 0

var numero = 1
var aumento_probabilidade: float = 0.1  # Aumento da probabilidade do inimigo 0 a cada minuto

var tempo_passado_aumento_vida: float = 0.0
var multiplicador_vida: float = 1.2

func _ready() -> void:
	sol.rotation_degrees.y = 0 
	
	Global.criacao_no_pai = self
	audio_stream_player.play()
	
	# Verifique se o número de probabilidades corresponde ao número de inimigos
	if inimigos.size() != probabilidades.size():
		push_error("O número de probabilidades deve corresponder ao número de inimigos.")

func _exit_tree() -> void:
	Global.criacao_no_pai = null

func _physics_process(delta: float) -> void:
	sol.rotate_y(velocidade_rotacao * delta)  # A rotação é baseada no tempo, o que cria o efeito contínuo
	
	if sol.rotation_degrees.y >= 360:
		sol.rotation_degrees.y = 0
	
	if Global.inimigos_ativos < Global.max_inimigos_ativos:
		for i in range(Global.zumbis_locais_ruins):
			Global.zumbis_locais_ruins -= 1
			_spawn_enemy()
			Global.inimigos_ativos += 1 

func _on_timer_spawn_inimigo_timeout() -> void:
	if Global.inimigos_ativos < Global.max_inimigos_ativos:
		_spawn_enemy()
		print(Global.inimigos_ativos)
		Global.inimigos_ativos += 1 

func _spawn_enemy():
	var posicao_inimigo = Vector3.ZERO
	var camera_transform = camera.global_transform
	var camera_position = camera_transform.origin

	# Resolução da câmera
	var camera_width = 1280
	var camera_height = 720

	while true:
		var offset_direction = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
		var offset_distance = randf_range(spawn_margin, spawn_margin + 50)
		var offset = offset_direction * offset_distance
		
		posicao_inimigo = camera_position + offset
		posicao_inimigo.y = 0

		var screen_pos = camera.unproject_position(posicao_inimigo)
		if screen_pos.x < 0 or screen_pos.x > camera_width or screen_pos.y < 0 or screen_pos.y > camera_height:
			break 
	
	var tipo_inimigo = _get_random_inimigo()

	Global.instantiate_node(inimigos[tipo_inimigo], posicao_inimigo, self)

func _get_random_inimigo() -> int:
	var total_probabilidade = 0.0
	for prob in probabilidades:
		total_probabilidade += prob
	
	var escolha = randf() * total_probabilidade
	var acumulado = 0.0
	
	for i in range(probabilidades.size()):
		acumulado += probabilidades[i]
		if escolha < acumulado:
			return i
	
	return 0  # Caso nenhuma probabilidade seja selecionada, retorna o primeiro inimigo

func _on_timer_dificuldade_timeout() -> void:
	tempo_passado += timer_dificuldade.wait_time
	tempo_passado_aumento_vida += timer_dificuldade.wait_time
	
	if tempo_passado < tempo_total:
		var minutos_passados = int(tempo_passado / 60)
		var probabilidade_inimigo_0 = min(1.0, 0.2 * minutos_passados)  # Limita a probabilidade a 1.0
		var restante = 1.0 - probabilidade_inimigo_0

		for i in range(1, probabilidades.size()):
			probabilidades[i] = restante / (probabilidades.size() - 1)
		
		probabilidades[0] = probabilidade_inimigo_0

		var progressao: float = tempo_passado / tempo_total
		var reducao: float = 0.05 * (1 + progressao)  # Redução maior conforme o tempo avança
		
		#print(progressao)
		#print(reducao)
		if timer_spawn_inimigo.wait_time > 0.1:
			timer_spawn_inimigo.wait_time = max(timer_spawn_inimigo.wait_time - reducao, 0.25)  
			#print("Inimigo", numero, "spawn time:", timer_spawn_inimigo.wait_time)
		
		# Aumenta a vida dos inimigos a cada minuto
		
		if tempo_passado_aumento_vida >= 120.0:
			_aumentar_vida_inimigos()
			tempo_passado_aumento_vida = 0.0  # Reseta o tempo do aumento

	else:
		timer_dificuldade.stop()

func _aumentar_vida_inimigos() -> void:
	
	for inimigo in get_tree().get_nodes_in_group("inimigos"):
		if inimigo.has_method("aumentar_vida"):
			inimigo.aumentar_vida(multiplicador_vida)
