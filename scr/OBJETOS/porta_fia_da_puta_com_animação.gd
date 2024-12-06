extends Node3D


@export var highlight_material: StandardMaterial3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var Cubo_002_meshinstance: MeshInstance3D = $Cubo_002
@onready var Cubo_meshinstance: MeshInstance3D = $Cubo
@onready var Plano_meshinstance: MeshInstance3D = $Plano
@onready var Cubo_001_meshinstance: MeshInstance3D = $Cubo_001

@onready var Cubo_002_material: StandardMaterial3D = Cubo_002_meshinstance.mesh.surface_get_material(0)
@onready var Cubo_material: StandardMaterial3D = Cubo_meshinstance.mesh.surface_get_material(0)
@onready var Plano_material: StandardMaterial3D = Plano_meshinstance.mesh.surface_get_material(0)
@onready var Cubo_001_material: StandardMaterial3D = Cubo_001_meshinstance.mesh.surface_get_material(0)

var is_open: bool = false

func open() -> void:
	is_open = true
	animation_player.play("CuboAction_005")
	
	## Fade the light in
	#var tween: Tween = get_tree().create_tween()
	#tween.tween_property($OmniLight3D, 'light_energy', 11.5, 0.5)
	#tween.tween_property($OmniLight3D, 'light_energy', 0, 2)

func add_highlight() -> void:
	Cubo_002_meshinstance.set_surface_override_material(0, Cubo_002_material.duplicate())
	Cubo_002_meshinstance.get_surface_override_material(0).next_pass = highlight_material
	
	Cubo_meshinstance.set_surface_override_material(0, Cubo_material.duplicate())
	Cubo_meshinstance.get_surface_override_material(0).next_pass = highlight_material
	
	Plano_meshinstance.set_surface_override_material(0, Plano_material.duplicate())
	Plano_meshinstance.get_surface_override_material(0).next_pass = highlight_material
	
	Cubo_001_meshinstance.set_surface_override_material(0, Cubo_001_material.duplicate())
	Cubo_001_meshinstance.get_surface_override_material(0).next_pass = highlight_material

func remove_highlight() -> void:
	Cubo_002_meshinstance.set_surface_override_material(0, null)
	Cubo_meshinstance.set_surface_override_material(0, null)
	Plano_meshinstance.set_surface_override_material(0, null)
	Cubo_001_meshinstance.set_surface_override_material(0, null)

# Open the chest if unopened
func _on_interactable_interacted(_interactor: Interactor) -> void:
	if not is_open:
		remove_highlight()
		$Interactable.queue_free()
		open()


# Add white outline
func _on_interactable_focused(_interactor: Interactor) -> void:
	if not is_open:
		add_highlight()

# Remove white outline
func _on_interactable_unfocused(_interactor: Interactor) -> void:
	remove_highlight()
