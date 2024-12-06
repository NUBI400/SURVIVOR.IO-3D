extends Node3D

signal SKIBIDIBITOILETE

@export var spawn_local1 : Node3D
@export var spawn_local2 : Node3D
@export var spawn_local3 : Node3D
@export var spawn_local4 : Node3D
@export var spawn_local5 : Node3D
@export var spawn_local6 : Node3D
@export var spawn_local7 : Node3D
@export var spawn_local8 : Node3D
@export var spawn_local9 : Node3D
@export var spawn_local10 : Node3D
@export var spawn_local11 : Node3D


var randow_spawn = null
var spawn_position = null

var Inimigo = preload("res://cenas/Inimigos/Zumbi.tscn")


var progress = true


func _process(delta):
	
	#print(Global.InimigosRound)
	
	
	if Global.InimigosRound <= 0: 
		Global.Round += 1
		Global.speed *= 1.1
		Global.Health *= 1.1
		SKIBIDIBITOILETE.emit()
	
	if Global.InimigosRound <= 0: 
		progress = false
	if progress == false && Global.InimigosRound != Global.ContagemInimigos:
		add_inimigo()
	
	
	
func _on_timer_timeout():
	Global.tempo_round += 1
	if Global.InimigosRound == Global.ContagemInimigos: 
		progress = true
	
	
	
func add_inimigo():
	var Inimi = Inimigo.instantiate()
	spawns()
	if spawn_position != null:
		Inimi.position = spawn_position
		add_child(Inimi)

func spawns():
	
	randow_spawn = randi_range(1,8)
	if randow_spawn == 1:
		spawn_position = spawn_local1.global_position
	if randow_spawn == 2:
		spawn_position = spawn_local2.global_position
	if randow_spawn == 3:
		spawn_position = spawn_local3.global_position
	if randow_spawn == 4:
		spawn_position = spawn_local4.global_position
	if randow_spawn == 5:
		spawn_position = spawn_local5.global_position
	if randow_spawn == 6:
		spawn_position = spawn_local6.global_position
	if randow_spawn == 7:
		spawn_position = spawn_local7.global_position
	if randow_spawn == 8:
		spawn_position = spawn_local8.global_position
	if randow_spawn == 9:
		spawn_position = spawn_local9.global_position
	if randow_spawn == 10:
		spawn_position = spawn_local10.global_position
	if randow_spawn == 11:
		spawn_position = spawn_local11.global_position
			
	

func contagem():
	Global.ContagemInimigos += 10
