extends StaticBody3D

signal weapons

@export var _weapon_name: String
@export var _current_ammo: int
@export var _reserve_ammo: int

@export_enum("Weapon","Ammo") var TYPE = "Weapon"

var Pick_Up_Ready: bool = true

func _ready():
	print("aaaaaa")

func Set_Ammo(w_name: String, c_ammo : int, r_ammo : int):
	if w_name == _weapon_name:
		_current_ammo = c_ammo
		_reserve_ammo = r_ammo



func _on_interactable_interacted(interactor):
	if Global.pontos >= Global.preço_revolver and _weapon_name == "Magnun":
		Global.pontos -= Global.preço_revolver
		emit_signal("weapons", _weapon_name, _current_ammo, _reserve_ammo, TYPE, Pick_Up_Ready)
	
	if Global.pontos >= Global.preço_mp7 and _weapon_name == "MP7":
		Global.pontos -= Global.preço_mp7
		emit_signal("weapons", _weapon_name, _current_ammo, _reserve_ammo, TYPE, Pick_Up_Ready)
	
	if Global.pontos >= Global.preço_shotgun and _weapon_name == "ShotGun":
		Global.pontos -= Global.preço_shotgun
		emit_signal("weapons", _weapon_name, _current_ammo, _reserve_ammo, TYPE, Pick_Up_Ready)
	
	if Global.pontos >= Global.preço_medkit and _weapon_name == "medkit" and Global.health_player < 3:
		Global.pontos -= Global.preço_medkit
		Global.health_player += 1
		if Global.health_player > 3:
			Global.health_player = 3

func _on_interactable_focused(interactor):
	print("a")
	if _weapon_name == "Magnun":
		Global.preço_revolver_visivel = true 
	if _weapon_name == "MP7":
		Global.preço_mp7_visivel = true 
	if _weapon_name == "ShotGun":
		Global.preço_shotgun_visivel = true
	if _weapon_name == "medkit":
		Global.preço_medkit_visivel = true

func _on_interactable_unfocused(interactor):
	if _weapon_name == "Magnun":
		Global.preço_revolver_visivel = false 
	if _weapon_name == "MP7":
		Global.preço_mp7_visivel = false 
	if _weapon_name == "ShotGun":
		Global.preço_shotgun_visivel = false
	if _weapon_name == "medkit":
		Global.preço_medkit_visivel = false
