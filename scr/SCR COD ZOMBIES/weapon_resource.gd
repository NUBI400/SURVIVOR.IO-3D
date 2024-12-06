extends Resource

class_name Weapon_Resource

signal UpdateOverlay
signal Zoom

@export var Weapon_Name: String
@export var Activate_Anim: String
@export var Shoot_Anim: String
@export var Reload_Anim: String
@export var Deactivate_Anim: String
@export var Out_Of_Ammo_Anim: String
@export var Melee_Anim: String
@export var Drop_Anim: String




@export var Current_Ammo: int
@export var Reserve_Ammo: int
@export var Magazine: int
@export var Max_Ammo: int

@export var AutoFire: bool
@export var Weapon_Range : int
@export var Damage : int
@export var Melee_Damage: float


@export var Can_Be_Dropped: bool
@export var Weapon_Drop: PackedScene

#@export_flags("HitScan", "Projectile") var Type
@export var Projectile_To_Load: PackedScene
#@export var Projectile_Velocity: int
@export var Incremental_Reload: bool = false


@export var Secondary_Fire_Resource: SecondaryFireResource
var Base_Property: Dictionary
var Secondary_Mode = false

func Secondary_Fire():
	if Secondary_Fire_Resource:
		Secondary_Mode = true
		
		if Secondary_Fire_Resource.LoadOverlay:
			UpdateOverlay.emit(true,Secondary_Fire_Resource.Overlay)
			
		if Secondary_Fire_Resource.Zoom:
			Zoom.emit(Secondary_Fire_Resource.Zoom_Amount)
			
		#if Secondary_Fire_Resource.ChangeSpray:
			#ChangeSprayVector(Secondary_Fire_Resource.NewSprayVector)
			#
		if Secondary_Fire_Resource.UpdateFlags:
			CheckFlags(Secondary_Fire_Resource.Flags)

func Secondary_Fire_Released():
	if Secondary_Fire_Resource:
		Secondary_Mode = false
		
		if Secondary_Fire_Resource.LoadOverlay:
			UpdateOverlay.emit(false)
			
		if Secondary_Fire_Resource.Zoom:
			Zoom.emit()
			
		#if Secondary_Fire_Resource.ChangeSpray:
			#ChangeSprayVector(Base_Spray_Vector)
			
		if Secondary_Fire_Resource.UpdateFlags:
			ResetFlags()

func CheckFlags(flags: Dictionary):
	for f in flags:
		Base_Property[f] = get(f)
		set(f,flags[f])

func ResetFlags():
	for p in Base_Property:
		set(p,Base_Property[p])
