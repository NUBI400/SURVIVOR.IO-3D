extends Node3D

@onready var lanterna = $"."
@onready var lanterna_light = $lanternamesh/SpotLight3D
@onready var lanterna_sound =$lanternamesh/AudioStreamPlayer3D
@onready var animation_player_lanterna = $AnimationPlayer



func pegar_lanterna(delta):
		if lanterna.visible == true:
			lanterna_light.visible = false
			animation_player_lanterna.play("descendo")
			await get_tree().create_timer(0.2).timeout
			lanterna.visible = false
		else:
			lanterna.visible = true
			animation_player_lanterna.play("subindo")



func lanterna_obj(delta):
	
	if Input.is_action_just_pressed("mouse1"):
		lanterna_light.visible = !lanterna_light.visible
		lanterna_sound.play()
