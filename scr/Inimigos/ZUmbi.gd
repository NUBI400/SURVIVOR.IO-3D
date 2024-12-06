extends "res://scr/Inimigos/base_inimigo.gd"

var medidor = 1
var player_in_area = false
var direction_player = 0

#@onready var animation_player = $Sketchfab_Scene/Sketchfab_model/Root/Armature/Skeleton3D/AnimationPlayer

var target_position = Vector3()

@onready var animation_player: AnimationPlayer = $Alien/AnimationPlayer

func _ready():
	visible = false
	animation_player.play("zbs_phobos_qc_skeleton|zbs_run")
	await get_tree().create_timer(1).timeout
	executar_codigo = true


func _physics_process(delta: float) -> void:
	if executar_codigo:
		if morra > 0:
			morra -= delta
			if not is_on_floor():
				Global.zumbis_locais_ruins += 1
				Global.inimigos_ativos -= 1 
				queue_free()
		else:
			visible = true
			add_to_group("Target")
	
	
	if Health <= 0:
		Global.pontos += 5
		Global.inimigos_ativos -= 1 
		queue_free()

	if not atordoado:
		target_position = Global.Player_Pos 
		var direction = (target_position - global_position).normalized()
	
		if visible == true:
			velocity = direction* speed / 10 
		
		move_and_slide()
	else:
		print("Inimigo está atordoado, não se movendo")
	
	look_at(Vector3(target_position.x, global_position.y, target_position.z), Vector3.UP)
	gravidade(delta)
