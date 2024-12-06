extends Node3D

@export var itens_usaveis : Node3D

@export var highlight_material: StandardMaterial3D


@onready var Cilindro: MeshInstance3D = $Cilindro
@onready var Cubo: MeshInstance3D = $Cubo
@onready var Cubo_001: MeshInstance3D = $Cubo_001
@onready var Plano: MeshInstance3D = $Plano
@onready var Plano_001: MeshInstance3D = $Plano_001
@onready var Plano_002: MeshInstance3D = $Plano_002

@onready var Cilindro_material: StandardMaterial3D = Cilindro.mesh.surface_get_material(0)
@onready var Cubo_material: StandardMaterial3D = Cubo.mesh.surface_get_material(0)
@onready var Cubo_001_material: StandardMaterial3D = Cubo_001.mesh.surface_get_material(0)
@onready var Plano_material: StandardMaterial3D = Plano.mesh.surface_get_material(0)
@onready var Plano_001_material: StandardMaterial3D = Plano_001.mesh.surface_get_material(0)
@onready var Plano_002_material: StandardMaterial3D = Plano_002.mesh.surface_get_material(0)

var is_open: bool = false

func open() -> void:
	itens_usaveis.pegou_item = 2
	queue_free()
	
	## Fade the light in
	#var tween: Tween = get_tree().create_tween()
	#tween.tween_property($OmniLight3D, 'light_energy', 11.5, 0.5)
	#tween.tween_property($OmniLight3D, 'light_energy', 0, 2)

func add_highlight() -> void:
	Cilindro.set_surface_override_material(0, Cilindro_material.duplicate())
	Cilindro.get_surface_override_material(0).next_pass = highlight_material
	
	Cubo.set_surface_override_material(0, Cubo_material.duplicate())
	Cubo.get_surface_override_material(0).next_pass = highlight_material
	
	Cubo_001.set_surface_override_material(0, Cubo_001_material.duplicate())
	Cubo_001.get_surface_override_material(0).next_pass = highlight_material
	
	Plano.set_surface_override_material(0, Plano_material.duplicate())
	Plano.get_surface_override_material(0).next_pass = highlight_material

	Plano_001.set_surface_override_material(0, Plano_001_material.duplicate())
	Plano_001.get_surface_override_material(0).next_pass = highlight_material

	Plano_002.set_surface_override_material(0, Plano_002_material.duplicate())
	Plano_002.get_surface_override_material(0).next_pass = highlight_material


func remove_highlight() -> void:
	Cilindro.set_surface_override_material(0, null)
	Cubo.set_surface_override_material(0, null)
	Cubo_001.set_surface_override_material(0, null)
	Plano.set_surface_override_material(0, null)
	Plano_001.set_surface_override_material(0, null)
	Plano_002.set_surface_override_material(0, null)

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
