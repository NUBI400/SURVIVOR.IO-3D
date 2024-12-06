extends CharacterBody3D


@export var joystick_left : VirtualJoystick



# Player nodes
@onready var camera_3d = $Nek/Head/Eyes/Camera3D
@onready var nek = $Nek
@onready var eyes = $Nek/Head/Eyes
@onready var head = $Nek/Head
@onready var standing_collision_shape = $Standing_collision_shape

@onready var animation_player_legs: AnimationPlayer = $Robo_model/AnimationPlayer_legs
@onready var animation_player_corpo: AnimationPlayer = $Robo_model/AnimationPlayer_corpo


@onready var corpo = $Robo_model
@onready var area_dead = $area_dead

# Raycasts
@onready var ray_cast_3d = $raycasts/RayCast3D
@onready var ray_cast_3d_2 = $raycasts/RayCast3D2
@onready var ray_cast_3d_3 = $raycasts/RayCast3D3
@onready var ray_cast_3d_4 = $raycasts/RayCast3D4
@onready var ray_cast_3d_5 = $raycasts/RayCast3D5

# Shaders
@onready var lineshaders = $Shaders/Lineshaders
@onready var subimerso_shader = $Shaders/Subimerso
@onready var analoghorrorshaders = $Shaders/Analoghorrorshaders

@onready var looking_area: Area3D = $Looking_area

@onready var canvas: CanvasLayer = $CanvasLayer

@export var ScreanShake : Node
@onready var damage_anim: AnimationPlayer = $Robo_model/damage_anim

# Vida
var health_back_become = false

# Speed vars
var current_speed = 40.0
var sprinting_speed = 80.0
var crouching_speed = 20.0
var flying_speed = 20.0
var subimerso_speed = 20.0

var morte = false

# Movement vars
const accel = 90
const FRICTION = 0.85
var crouching_depth = -0.8
var troca_de_velocidade_speed = 5.0
var troca_de_velocidade_correndo_speed = 2.0
var air_lerp_speed = 3
var last_velocity = Vector3.ZERO

var input_dir = Vector2.ZERO

# Input vars
var mouse = Vector2()
var MOUSE_SPEED_PADRAO : float
var MOUSE_SPEED_INSPECION = 0.04
var mouse_sens = MOUSE_SPEED_PADRAO 
var direction = Vector3.ZERO

var nearest_enemy = null 

# Tanke damage vars
var taking_damage = false
var damage_per_second = 1  # Quantidade de dano por segundo
var damage_timer = 0.0  # Temporizador para aplicar dano

var last_look_at_direction = Vector3.FORWARD


func _ready():
	animation_player_corpo.play("Armature|Corpo")
	canvas.uptate_ui_player(Global.health_player)
	Global.revolver_possui = true
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	head.rotation.x = 0
	
	for inimigo in get_tree().get_nodes_in_group("inimigos"):
		inimigo.connect("dano_aplicado", _on_inimigo_dano_aplicado)

func _physics_process(delta):
	
	if Input.is_action_just_pressed("jump"):
		ScreanShake.start_screen_shake(0.2, 0.5)  # Intensidade 1.0, Duração 0.5 segundos


	
	
	if morte == false:
		input_dir = Input.get_vector("Esquerda", "Direita", "Cima", "Baixo")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if direction:
			animation_player_legs.play("Armature|wallk_leg")
			velocity.x += direction.x * Global.walking_speed * delta
			velocity.z += direction.z * Global.walking_speed * delta
		else:
			animation_player_legs.play("Armature|Idle")
		
		
		rotate_towards_enemy_or_movement(delta)
		Global.Player_Pos = position
		
		# Movimentos
		movement(delta)
		gravidade(delta)
		move_and_slide()
		velocity.x *= FRICTION
		velocity.z *= FRICTION
		
		if taking_damage:
			damage_timer += delta
			if damage_timer >= 0.2:  # Aplica o dano a cada 0.2 segundos
				damage_anim.play("damage")
				ScreanShake.start_screen_shake(0.15, 0.2)
				Global.health_player -= damage_per_second
				canvas.uptate_ui_player(Global.health_player)
				damage_timer = 0.0
				if Global.health_player <= 0:
					get_tree().quit()

func _on_inimigo_dano_aplicado(dano: float) -> void:
	taking_damage = true
	damage_per_second = dano

func get_nearest_enemy(player_position: Vector3) -> Node3D:
	var enemies = get_tree().get_nodes_in_group("Target")
	var nearest_enemy: Node3D = null
	var min_distance = INF
	
	for enemy in enemies:
		# Verifica se o inimigo está dentro da área
		if looking_area.get_overlapping_bodies().has(enemy):
			# Calcula a distância no plano XZ
			var distance = player_position.distance_to(Vector3(enemy.global_transform.origin.x, player_position.y, enemy.global_transform.origin.z))
			if distance < min_distance:
				min_distance = distance
				nearest_enemy = enemy
	
	return nearest_enemy

func rotate_towards_enemy_or_movement(delta):
	var player_position = global_transform.origin
	nearest_enemy = get_nearest_enemy(player_position)
	
	var target_direction = last_look_at_direction  # Mantém a última direção por padrão
	
	if nearest_enemy != null:
		# Posição do inimigo
		var enemy_position = nearest_enemy.global_transform.origin 
		# Calcula a direção alvo
		target_direction = (Vector3(enemy_position.x, player_position.y, enemy_position.z) - player_position).normalized()
	elif direction.length() > 0:
		# Se há movimento, o robô deve olhar para a direção do movimento
		var look_at_position = player_position + direction * 5  # Ajuste o fator 5 conforme necessário para definir a distância de "olhar"
		target_direction = (look_at_position - player_position).normalized()
	
	# Suaviza a rotação usando lerp
	last_look_at_direction = last_look_at_direction.lerp(target_direction, delta * troca_de_velocidade_speed)
	
	# Faz o corpo rotacionar em direção à direção suavizada
	var look_at_position = player_position + last_look_at_direction * 5
	corpo.look_at(Vector3(look_at_position.x, player_position.y, look_at_position.z), Vector3.UP)
	corpo.rotation.x = 0
	nek.look_at(Vector3(look_at_position.x, player_position.y, look_at_position.z), Vector3.UP)
	nek.rotation.x = 0



func movement(delta):
	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*troca_de_velocidade_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*air_lerp_speed)

func gravidade(delta):
	if not is_on_floor():
		velocity.y -= Global.gravity * delta * 2.5

# Função que detecta quando o jogador entra na área de dano
func _on_area_dead_area_entered(area):
	if area.is_in_group("damage"):
		taking_damage = true  # Começa a aplicar dano constante

# Função que detecta quando o jogador sai da área de dano
func _on_area_dead_area_exited(area):
	if area.is_in_group("damage"):
		taking_damage = false  # Para de aplicar dano constante
		damage_timer = 0.0  # Reseta o temporizador de dano


func _on_animation_player_corpo_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Armature|Corpo":
		animation_player_corpo.play("Armature|Corpo_subindo_armas")
		
