extends RigidBody3D


@export var highlight_material: StandardMaterial3D

#@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lanterna_meshinstance: MeshInstance3D = $Cube
@onready var lanterna_material: StandardMaterial3D = lanterna_meshinstance.mesh.surface_get_material(0)

var is_open: bool = false

@export var mirrored = false
@export var Mirror_What : Node3D

var Health = 60


func _physics_process(delta):
	if mirrored:
		position.y = Mirror_What.get_position().y
		position.z = Mirror_What.get_position().z
		position.x = Mirror_What.get_position().x * -1
		rotation.y = Mirror_What.rotation.y
		rotation.z = Mirror_What.rotation.z
		rotation.x = Mirror_What.rotation.x


func Hit_Successful(Damage, _Direction: Vector3 = Vector3.ZERO, _Position: Vector3 = Vector3.ZERO):
	var Hit_Position = _Position - get_global_transform().origin 
	Health -= Damage
	#print("Target Health:" + str(Health))
	if Health <= 0:
		queue_free()
		
	if _Direction != Vector3.ZERO:
		apply_impulse((_Direction*Damage),Hit_Position)

func open() -> void:
	pass
	#queue_free()

func add_highlight() -> void:
	lanterna_meshinstance.set_surface_override_material(0, lanterna_material.duplicate())
	lanterna_meshinstance.get_surface_override_material(0).next_pass = highlight_material

func remove_highlight() -> void:
	lanterna_meshinstance.set_surface_override_material(0, null)




# Open the chest if unopened
func _on_interactable_interacted(_interactor: Interactor) -> void:
	if not is_open:
		open()

# Add white outline
func _on_interactable_focused(_interactor: Interactor) -> void:
	if not is_open:
		add_highlight()

# Remove white outline
func _on_interactable_unfocused(_interactor: Interactor) -> void:
	remove_highlight()
