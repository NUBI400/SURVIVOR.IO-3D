extends Node3D

signal Add_Signal_To_HUD
signal Weapon_Changed
signal Update_Ammo
signal Update_Weapon_Stack
signal Hit_Successfull


signal weapons_sinal
signal weapons

signal Connect_Weapon_To_HUD
@onready var main_sight = $"../../../../../CanvasLayer/Main_Sight"

@onready var Melee_Hitbox = $Melee_Hitbox
@onready var Animation_Player = $FPS_Rig/AnimationPlayer
@onready var Bullet_Point = $FPS_Rig/Bullet_Point

const Debug_Bullet = preload("res://cenas/CENAS COD ZOMBIES/bullet_debug.tscn")

var Current_Weapon = null

var WeaponStack:Array = [] # ARRAY DAS ARMAS EM POSSE DO JOGADOR

var Weapon_Indicator = 0

var Next_Weapon: String

var Weapon_List: Dictionary = {}

var shot_tween

@export var _weapon_resources: Array[Weapon_Resource]

@export var Start_Weapons: Array[String]

enum {NULL, HITSCAN, PROJECTILE}

var Collision_Exclusion = []


var reloading = false

func _ready():
	Initialize(Start_Weapons) #começa na primeira arma da pilha


func _input(event):
	if event.is_action_pressed("Weapon_UP"):
		var GetRef = WeaponStack.find(Current_Weapon.Weapon_Name)
		GetRef = min(GetRef+1,WeaponStack.size()-1)
		
		exit(WeaponStack[GetRef])

	if event.is_action_pressed("Weapon_DOWN"):
		var GetRef = WeaponStack.find(Current_Weapon.Weapon_Name)
		GetRef = max(GetRef-1,0)

		exit(WeaponStack[GetRef])

	if event.is_action_pressed("mouse1"):
		if not Current_Weapon.Secondary_Mode == true:
			shoot()
		else:
			ADS_shoot()
	#
	if event.is_action_released("mouse1"):
		Shot_Count_Update()
	
	if event.is_action_pressed("mouse2"):
		secondary()
		
	if event.is_action_released("mouse2"):
		reset_secondary()
	
	if event.is_action_pressed("Reload"):
		if  not Current_Weapon.Secondary_Mode:
			reload()
			print("1")

#
	#if event.is_action_pressed("Drop"):
		#drop(Current_Weapon.Weapon_Name)
		
	if event.is_action_pressed("Melee"):
		melee()

func Initialize(_Start_Weapons: Array):
	for Weapons in _weapon_resources:
		Weapon_List[Weapons.Weapon_Name] = Weapons
		
		Connect_Weapon_To_HUD.emit(Weapons)
		
	for weapon_name in _Start_Weapons:
		WeaponStack.push_back(weapon_name)

	Current_Weapon = Weapon_List[WeaponStack[0]]

	Update_Weapon_Stack.emit(WeaponStack)
	enter()

func enter():
	Animation_Player.queue(Current_Weapon.Activate_Anim)
	Weapon_Changed.emit(Current_Weapon.Weapon_Name)
	Update_Ammo.emit([Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])

func exit(_next_weapon: String):
	if _next_weapon != Current_Weapon.Weapon_Name:
		if Animation_Player.get_current_animation() != Current_Weapon.Deactivate_Anim:
			Animation_Player.queue(Current_Weapon.Deactivate_Anim)
			Next_Weapon = _next_weapon

func Change_Weapon(weapon_name: String):
	Current_Weapon = Weapon_List[weapon_name]
	Next_Weapon = ""
	enter()
	

func drop(_name: String):
	if Weapon_List[_name].Can_Be_Dropped and WeaponStack.size() != 1:
		var Weapon_Ref = WeaponStack.find(_name,0)
		if Weapon_Ref != -1:
			WeaponStack.pop_at(Weapon_Ref)
			Update_Weapon_Stack.emit(WeaponStack)

			if Weapon_List[_name].Weapon_Drop:
				var Weapon_Dropped = Weapon_List[_name].Weapon_Drop.instantiate()
				Weapon_Dropped._current_ammo = Weapon_List[_name].Current_Ammo
				Weapon_Dropped._reserve_ammo = Weapon_List[_name].Reserve_Ammo
#
				#Weapon_Dropped.set_global_transform(Bullet_Point.get_global_transform())
				#get_tree().get_root().add_child(Weapon_Dropped)

				#Animation_Player.play(Current_Weapon.Drop_Anim)
				Weapon_Ref  = max(Weapon_Ref-1,0)
				exit(WeaponStack[Weapon_Ref])
	else:
		return


func melee():
	var Current_Anim = Animation_Player.get_current_animation()
	
	if Current_Anim == Current_Weapon.Shoot_Anim:
		return
		
	if Current_Anim != Current_Weapon.Melee_Anim:
		Animation_Player.play(Current_Weapon.Melee_Anim)
		if Melee_Hitbox.is_colliding():
			var colliders = Melee_Hitbox.get_collision_count()
			for c in colliders:
				var Target = Melee_Hitbox.get_collider(c)
				if Target.is_in_group("Target") and Target.has_method("Hit_Successful"):
					Hit_Successfull.emit()
					var Direction = (Target.global_transform.origin - owner.global_transform.origin).normalized()
					var Position =  Melee_Hitbox.get_collision_point(c)
					Target.Hit_Successful(Current_Weapon.Melee_Damage, Direction, Position)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == Current_Weapon.Shoot_Anim or Current_Weapon.Secondary_Fire_Resource.Seconday_Fire_Animation:
		if Current_Weapon.AutoFire == true:
				if Input.is_action_pressed("mouse1"):
					if not Current_Weapon.Secondary_Mode == true:
						shoot()
					else:
						ADS_shoot()
	
	
	if anim_name == Current_Weapon.Deactivate_Anim:
		Change_Weapon(Next_Weapon)
	
	if anim_name == Current_Weapon.Reload_Anim:
		Calculate_Reload()

	
	
	CheckSecondaryMode()

func CheckSecondaryMode():
	if Current_Weapon.Secondary_Mode == true:
		if !Input.is_action_pressed("mouse2"):
			reset_secondary()


func Shot_Count_Update():
	pass
	#shot_tween = get_tree().create_tween()
	#shot_tween.tween_property(self,"_count",0,1)

func shoot():
	if Current_Weapon.Current_Ammo != 0:
		if not Animation_Player.is_playing():
			Animation_Player.queue(Current_Weapon.Shoot_Anim)
			Current_Weapon.Current_Ammo -= 1
			Update_Ammo.emit([Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
			
			var Spread = Vector2.ZERO
			Load_Projectile(Spread)
			
	else:
		if reloading:
			return
		
		if reloading == false:
			reloading = true
			reload()
			print(Current_Weapon.Current_Ammo)



func Load_Projectile(_spread):
	var _projectile:Projectile = Current_Weapon.Projectile_To_Load.instantiate()
	Bullet_Point.add_child(_projectile)
	Add_Signal_To_HUD.emit(_projectile)
	_projectile._Set_Projectile(Current_Weapon.Damage,_spread,Current_Weapon.Weapon_Range)

func reload():
	print("reload")
	if Current_Weapon.Current_Ammo == Current_Weapon.Magazine:
		return
	elif not Animation_Player.is_playing():
		
		if Current_Weapon.Reserve_Ammo != 0:
			
			Animation_Player.queue(Current_Weapon.Reload_Anim)
	
		else:
			Animation_Player.queue(Current_Weapon.Out_Of_Ammo_Anim)
	reset_secondary()

func Calculate_Reload():
	if Current_Weapon.Current_Ammo == Current_Weapon.Magazine:
		var anim_legnth = Animation_Player.get_current_animation_length()
		Animation_Player.advance(anim_legnth)
		return
		
	var Mag_Amount = Current_Weapon.Magazine
	
	if Current_Weapon.Incremental_Reload:
		Mag_Amount = Current_Weapon.Current_Ammo+1
		
	var Reload_Amount = min(Mag_Amount-Current_Weapon.Current_Ammo,Mag_Amount,Current_Weapon.Reserve_Ammo)
	
	Current_Weapon.Current_Ammo = Current_Weapon.Current_Ammo+Reload_Amount
	Current_Weapon.Reserve_Ammo = Current_Weapon.Reserve_Ammo-Reload_Amount
	
	Update_Ammo.emit([Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
	reloading = false
	
	if Input.is_action_pressed("mouse1"):
		shoot()
	
	
	Shot_Count_Update()
	reset_secondary()




func _on_pick_up(_weapon_name, _current_ammo, _reserve_ammo, TYPE, Pick_Up_Ready):
	
	var Weapon_In_Stack = WeaponStack.find(_weapon_name,0)
	
	if Weapon_In_Stack != -1:
		

		var remaining
#
		remaining = Add_Ammo(_weapon_name, _current_ammo+_reserve_ammo)
		_current_ammo = min(remaining, Weapon_List[_weapon_name].Magazine)
		_reserve_ammo = max(remaining - _current_ammo,0)
	
	
		
	elif TYPE == "Weapon":
			if Pick_Up_Ready == true:
				var GetRef = WeaponStack.find(Current_Weapon.Weapon_Name)
				WeaponStack.insert(GetRef,_weapon_name)

				#Zero Out Ammo From the Resource
				Weapon_List[_weapon_name].Current_Ammo = _current_ammo
				Weapon_List[_weapon_name].Reserve_Ammo = _reserve_ammo
				
				
				
				Update_Weapon_Stack.emit(WeaponStack)
				exit(_weapon_name)
	
	


func Add_Ammo(_Weapon: String, Ammo: int)->int:
	var _weapon = Weapon_List[_Weapon]

	var Required = _weapon.Max_Ammo - _weapon.Reserve_Ammo
	var Remaining = max(Ammo - Required,0)

	_weapon.Reserve_Ammo += min(Ammo, Required)

	Update_Ammo.emit([Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
	return Remaining



func secondary():
	if Current_Weapon.Secondary_Fire_Resource:
		if not Animation_Player.is_playing():
			Current_Weapon.Secondary_Fire()
			
			if Current_Weapon.Secondary_Fire_Resource.Secondary_Fire_Shoot:
				Secondary_Shoot(Current_Weapon.Secondary_Fire_Resource)
			main_sight.visible = false
			Animation_Player.queue(Current_Weapon.Secondary_Fire_Resource.Seconday_Fire_Animation)

func reset_secondary():
	if Current_Weapon.Secondary_Fire_Resource:
		if Current_Weapon.Secondary_Mode:
			if not Animation_Player.is_playing():
				Current_Weapon.Secondary_Fire_Released()
				if Current_Weapon.Secondary_Fire_Resource.Seconday_Fire_Animation_Reset:
					Animation_Player.queue(Current_Weapon.Secondary_Fire_Resource.Seconday_Fire_Animation_Reset)
					main_sight.visible = true


func Secondary_Shoot(secondary_resource):
	if secondary_resource.Ammo != 0:
		secondary_resource.Ammo  -= 1
		
		var Spread = Vector2.ZERO
		Load_Projectile(Spread)
		
		
		Animation_Player.queue(Current_Weapon.Secondary_Fire_Resource.Seconday_Fire_Animation)
	reset_secondary()



func ADS_shoot():
	if Current_Weapon.Current_Ammo != 0:
		if not Animation_Player.is_playing():
			Animation_Player.queue(Current_Weapon.Secondary_Fire_Resource.Seconday_Fire_Animation_Shoot)
			Current_Weapon.Current_Ammo -= 1
			Update_Ammo.emit([Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
			
			var Spread = Vector2.ZERO
			Load_Projectile(Spread)


	reset_secondary()

func _on_weapons_sinal(Weapon_Dropped):
	Weapon_Dropped.connect("weapons", Callable(self,"_on_pick_up"))
	emit_signal("weapons", Weapon_Dropped._weapon_name, Weapon_Dropped._current_ammo, Weapon_Dropped._reserve_ammo, Weapon_Dropped.TYPE, Weapon_Dropped.Pick_Up_Ready)
	
