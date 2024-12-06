extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var armas: VBoxContainer = $Control/CenterContainer/vbox/ARMAS/armas_scroll/VBOX_armas_scroll
@onready var loja: StaticBody3D = $"../.."

var mouse = Vector2()
@onready var vbox_armas_scroll: VBoxContainer = $Control/CenterContainer/vbox/ARMAS/armas_scroll/VBOX_armas_scroll

var current_weapon_data = null
var qual = null

signal open_or_not_open
signal weapons




@export var navigation_region_3d: NavigationRegion3D 



func _ready() -> void:
	animation_player.play("RESET")
	Global.loja_aberta = false

func _on_voltar_button_down() -> void:
	resume()
	qual = null
	_clear_current_weapon_data()

func _on_comprar_button_down() -> void:
	if current_weapon_data:
		var preco = current_weapon_data["preço"]
		var weapon_name = current_weapon_data["name"]
		
		# Verifica se a arma já foi comprada
		if Global.is_weapon_owned(weapon_name):
			qual = "already_owned"
			emit_signal("open_or_not_open", weapon_name, qual)
			return

		if Global.pontos >= preco:
			Global.pontos -= preco
			
			# Marca a arma como comprada no inventário global
			Global.mark_weapon_as_owned(weapon_name)
			
			# Emite o sinal 'weapons' com os dados salvos em 'current_weapon_data'
			emit_signal("weapons", 
				current_weapon_data["name"], 
				current_weapon_data["current_ammo"], 
				current_weapon_data["reserve_ammo"], 
				current_weapon_data["type"], 
				current_weapon_data["ready"]
			)
			qual = "open"
			emit_signal("open_or_not_open", weapon_name, qual)
		else:
			qual = "not_open"
			emit_signal("open_or_not_open", weapon_name, qual)

func resume():
	Global.loja_aberta = false
	get_tree().paused = false
	animation_player.play_backwards("blur")
	#_mouse_menu()

func paused():
	Global.loja_aberta = true
	get_tree().paused = true
	animation_player.play("blur")
	#_mouse_menu()

	if vbox_armas_scroll.get_child_count() > 0:
		var first_child = vbox_armas_scroll.get_child(0)
		if first_child is Control:
			first_child.grab_focus()

func _mouse_menu():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse = Vector2()

func _physics_process(delta: float) -> void:
	testEsc()

func testEsc():
	#if Input.is_action_just_pressed("esq") and !get_tree().paused:
		#paused()
	if Input.is_action_just_pressed("esq") and get_tree().paused:
		resume()
func _on_loja_arma_weapons(preço, _weapon_name, _current_ammo, _reserve_ammo, TYPE, Pick_Up_Ready) -> void:
	# Salva os dados da arma atual
	current_weapon_data = {
		"name": _weapon_name,
		"current_ammo": _current_ammo,
		"reserve_ammo": _reserve_ammo,
		"type": TYPE,
		"ready": Pick_Up_Ready,
		"preço": preço
	}

func _clear_current_weapon_data() -> void:
	# Limpa os dados da arma salva
	current_weapon_data = null
