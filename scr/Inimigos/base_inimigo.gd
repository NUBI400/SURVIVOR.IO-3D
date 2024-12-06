extends CharacterBody3D



@export var speed = 50
@export var Health = 50

@export var Player : CharacterBody3D 
@onready var nav = $NavigationAgent3D

var atordoado = false

var spawnado = false

var morra = 0.2
var executar_codigo: bool = false  # Variável para controlar a execução do código

@export var dano: float = 1.0


signal dano_aplicado(dano: float)


func _on_player_contact():
	emit_signal("dano_aplicado", dano)


func aumentar_vida(multiplicador: float) -> void:
	Health *= multiplicador


func gravidade(delta):
	velocity.y = -4
	
func Hit_Successful(Damage, _Direction: Vector3 = Vector3.ZERO, _Position: Vector3 = Vector3.ZERO, Knockback_Force: float = 0.0, Apply_Knockback: bool = false):
	Health -= Damage
	
	if Health > 0 and Apply_Knockback and Knockback_Force > 0:
		apply_knockback(-_Direction, Knockback_Force)

func apply_knockback(_Direction: Vector3, force: float):
	if not atordoado:
		atordoado = true
		velocity = -_Direction * force
		atordoado = false
