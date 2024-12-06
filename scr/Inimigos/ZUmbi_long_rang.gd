extends "res://scr/Inimigos/base_inimigo.gd"

var medidor = 1
var player_in_area = false
var direction_player = Vector3()
var minimum_distance = 10.0  # Distância mínima que o inimigo deve manter do jogador

@onready var animation_player = $Sketchfab_Scene/Sketchfab_model/Root/Armature/Skeleton3D/AnimationPlayer
@onready var attack_anim = $AnimationPlayer
@onready var projectile_scene = preload("res://cenas/CENAS COD ZOMBIES/bullet_enemy.tscn")
@onready var shoot_timer: Timer = $shoot_timer
@onready var marker_3d: Marker3D = $Marker3D


func _physics_process(delta):
	if morra > 0:
		morra -= delta
		velocity.x = 0
	else:
		if is_on_floor() == false:
			Global.zumbis_locais_ruins += 1
			queue_free()
		else:
			visible = true
			add_to_group("Target")

	if Health <= 0:
		Global.InimigosRound -= 1
		Global.pontos += 5
		queue_free()
		if Global.InimigosRound <= 0:
			Global.ContagemInimigos += 1

	if not atordoado:
		if player_in_area:
			var distance_to_player = global_position.distance_to(Global.Player_Pos)
			if distance_to_player < minimum_distance:
				# Move o inimigo para longe do jogador se estiver muito perto
				var flee_direction = (global_position - Global.Player_Pos).normalized()
				nav.target_position = global_position + flee_direction * speed * delta
			else:
				# Movimento normal
				var direction = nav.get_next_path_position() - global_position
				direction = direction.normalized()
				nav.target_position = Global.Player_Pos
				velocity = velocity.lerp(direction * speed, accel * delta)
				move_and_slide()
		else:
			# Movimento normal se o jogador não estiver na área
			var direction = nav.get_next_path_position() - global_position
			direction = direction.normalized()
			nav.target_position = Global.Player_Pos
			velocity = velocity.lerp(direction * speed, accel * delta)
			move_and_slide()

	else:
		print("Inimigo está atordoado, não se movendo")

	look_at(Vector3(Global.Player_Pos.x, global_position.y, Global.Player_Pos.z), Vector3.UP)
	gravidade(delta)

func _on_area_area_entered(area):
	if area.is_in_group("Player"):
		player_in_area = true
		direction_player = (Global.Player_Pos - global_position).normalized()
		shoot_projectile()

func _on_area_area_exited(area):
	if area.is_in_group("Player"):
		player_in_area = false
		shoot_timer.stop()

func shoot_projectile():
	var _projectile = projectile_scene.instantiate()
	marker_3d.add_child(_projectile)
	
	# Define a direção do projétil no momento do spawn
	_projectile.set_velocity(direction_player * _projectile.speed)
	_projectile.look_at(Global.Player_Pos, Vector3.UP)
	_projectile.set_as_top_level(true)

func _on_shoot_timer_timeout() -> void:
	if player_in_area:
		shoot_projectile()
	shoot_timer.start()  # Reinicia o timer para o próximo tiro
