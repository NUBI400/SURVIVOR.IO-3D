extends Button

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cadeado: TextureRect = $TextureRect

signal weapons

@export var _weapon_name: String
@export var _current_ammo: int
@export var _reserve_ammo: int

@export_enum("Weapon","Ammo") var TYPE = "Weapon"

var Pick_Up_Ready: bool = true
var preço = null

@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	var data = Global.guns_weapon_data.get(_weapon_name)
	if data:
		_current_ammo = data.municao_maxima
		_reserve_ammo = data.municao_maxima
		
func _physics_process(delta: float) -> void:
	match _weapon_name:
		"Magnun":
			preço = Global.preço_revolver
			if Global.revolver_possui == false:
				cadeado.visible = true
			else:
				cadeado.visible = false
		"MP7":
			preço = Global.preço_mp7
			if Global.mp7_possui == false:
				cadeado.visible = true
			else:
				cadeado.visible = false

func Set_Ammo(w_name: String, c_ammo : int, r_ammo : int):
	if w_name == _weapon_name:
		_current_ammo = c_ammo
		_reserve_ammo = r_ammo

func _on_button_down() -> void:
	emit_signal("weapons", preço, _weapon_name, _current_ammo, _reserve_ammo, TYPE, Pick_Up_Ready)


func open():
	
	match _weapon_name:
		"Magnun":
			if Global.revolver_possui == false:
				animation_player.play("fade")
				Global.revolver_possui = true
		"MP7":
			if Global.mp7_possui == false:
				animation_player.play("fade")
				Global.mp7_possui = true


func _on_focus_entered():
	Global.weapon_data = _weapon_name

func _not_open():
	animation_player.play("shake_and_flash")


func _on_loja_ui_open_or_not_open(current_weapon_data ,qual) -> void:
	
	match qual:
		"open":
			if current_weapon_data == _weapon_name:
				open()
		"not_open":
			if current_weapon_data == _weapon_name:
				_not_open()
