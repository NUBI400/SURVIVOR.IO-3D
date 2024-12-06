extends RigidBody3D

signal Hit_Successful

@export var Damage: int = 1
@export var speed: float = 20.0

func _ready():
	# Definir a velocidade inicial
	set_linear_velocity(transform.basis.z * speed)

func set_velocity(velocity: Vector3):
	set_linear_velocity(velocity)
#func _on_body_entered(body):
	#if body.is_in_group("Player") && body.has_method("Hit_Successful"):
		#body.Hit_Successful(Damage)
		#emit_signal("Hit_Successful")
#
	#queue_free()

func _on_timer_timeout():
	queue_free()
