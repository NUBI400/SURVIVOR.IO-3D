extends Node3D
class_name Projectile

signal Hit_Successfull
signal Hit_Successfull_shotgun

@export_enum("Hitscan", "Rigidbody_Projectile") var Projectile_Type: String = "Hitscan"
@export var Projectile_Velocity: int
@export var Expirey_Time: int = 10
@export var Display_Debug_Decal: bool = true
@export var Rigid_Body_Projectile: PackedScene

@export var Apply_Knockback: bool = false
@export var Knockback_Force: float = 10.0 

@export_enum("null", "Ricochetes", "Penetrations") var Projectile_stile: String = "null"
@export var Max_Ricochetes: int = 0
@export var Max_Penetrations: int = 0 

@onready var Debug_Bullet = preload("res://cenas/CENAS COD ZOMBIES/bullet_debug.tscn")

var Damage: float = 0
var Projectiles_Spawned = []
var ricochetes_remaining: int
var penetrations_remaining: int

func _ready() -> void:
	get_tree().create_timer(Expirey_Time).timeout.connect(_on_timer_timeout)
	
	match Projectile_stile:
		"Ricochetes":
			ricochetes_remaining = Max_Ricochetes
		"Penetrations":
			penetrations_remaining = Max_Penetrations

func _Set_Projectile(_Damage: int = 0, _spread: Vector2 = Vector2.ZERO, _Range: int = 1000):
	Damage = _Damage
	Fire_Projectile(_spread, _Range, Rigid_Body_Projectile)

func Fire_Projectile(_spread: Vector2, _range: int, _proj: PackedScene):
	var Camera_Collision = Camera_Ray_Cast(_spread, _range)
	
	match Projectile_Type:
		"Hitscan":
			Hit_Scan_Collision(Camera_Collision, Damage)
		"Rigidbody_Projectile":
			Launch_Rigid_Body_Projectile(Camera_Collision[1], _proj)

func Camera_Ray_Cast(_spread: Vector2 = Vector2.ZERO, _range: float = 1000):
	var player_position = global_transform.origin  
	var nearest_enemy = get_nearest_enemy(player_position)
	var Ray_End = null
	
	if nearest_enemy != null:
		Ray_End = Vector3(nearest_enemy.global_transform.origin.x, player_position.y, nearest_enemy.global_transform.origin.z)
	else:
		var direction = Vector2(1, 0)  
		Ray_End = player_position + Vector3(direction.x, 0, direction.y) * _range
	
	var New_Intersection = PhysicsRayQueryParameters3D.create(player_position, Ray_End)
	New_Intersection.set_collision_mask(0b1110111)
	
	var Intersection = get_world_3d().direct_space_state.intersect_ray(New_Intersection)
	
	if not Intersection.is_empty():
		var Collision = [Intersection.collider, Intersection.position]
		return Collision
	else:
		return [null, Ray_End]

func get_nearest_enemy(player_position: Vector3) -> Node3D:
	var enemies = get_tree().get_nodes_in_group("Target")  
	var nearest_enemy: Node3D = null
	var min_distance = INF

	for enemy in enemies:
		var distance = player_position.distance_to(Vector3(enemy.global_transform.origin.x, player_position.y, enemy.global_transform.origin.z))
		if distance < min_distance:
			min_distance = distance
			nearest_enemy = enemy

	return nearest_enemy

func Hit_Scan_Collision(Collision: Array, _damage):
	var Point = Collision[1]
	var Bullet_Point = get_parent()
	
	if Collision[0]:
		Load_Decal(Point)
		
		if Collision[0].is_in_group("Target"):
			var Bullet = get_world_3d().direct_space_state

			var Bullet_Direction = (Point - Bullet_Point.global_transform.origin).normalized()
			var New_Intersection = PhysicsRayQueryParameters3D.create(Bullet_Point.global_transform.origin, Point + Bullet_Direction * 2)

			var Bullet_Collision = Bullet.intersect_ray(New_Intersection)

			if Bullet_Collision:
				Hit_Scan_Damage(Bullet_Collision.collider, Bullet_Direction, Bullet_Collision.position, _damage)

func Hit_Scan_Damage(Collider, Direction, Position, _damage):
	if Collider.is_in_group("Target") and Collider.has_method("Hit_Successful"):
		Collider.Hit_Successful(_damage, Direction, Position, Knockback_Force, Apply_Knockback)
		Hit_Successfull.emit()
		
		print("a")
		
		match Projectile_stile:
			"null":
				queue_free()
			"Penetrations":
				penetrations_remaining -= 1
				if penetrations_remaining <= 0:
					queue_free()
				else:
					Load_Decal(Position)
			"Ricochetes":
				ricochetes_remaining -= 1
				if ricochetes_remaining <= 0:
					queue_free()
				else:
					Load_Decal(Position)

func Load_Decal(_pos):
	if Display_Debug_Decal:
		var rd = Debug_Bullet.instantiate()
		var world = get_tree().get_root()
		world.add_child(rd)
		rd.global_translate(_pos)

func Launch_Rigid_Body_Projectile(_Point: Vector3, _projectile: PackedScene):
	var _proj = _projectile.instantiate()
	add_child(_proj)
	
	Projectiles_Spawned.push_back(_proj)

	_proj.body_entered.connect(_on_body_entered.bind(_proj))
	
	var _Direction = Vector3((_Point.x - global_transform.origin.x), 0, (_Point.z - global_transform.origin.z)).normalized()
	
	var up_vector = Vector3(0, 1, 0)  
	_proj.look_at(_Point, up_vector)
	
	_proj.set_as_top_level(true)
	_proj.set_linear_velocity(_Direction * Projectile_Velocity) 

	if Apply_Knockback:
		_proj.set("Apply_Knockback", Apply_Knockback)
		_proj.set("Knockback_Force", Knockback_Force)

func _on_body_entered(body, _proj):
	if body.is_in_group("Target") and body.has_method("Hit_Successful"):
		var player_position = get_tree().get_nodes_in_group("Player")[0].global_transform.origin
		var hit_direction = (body.global_transform.origin - player_position).normalized()
		body.Hit_Successful(Damage, hit_direction, _proj.global_transform.origin, Knockback_Force, Apply_Knockback)
		Hit_Successfull.emit()
		
		match Projectile_stile:
			"null":
				Load_Decal(_proj.get_position())
				_proj.queue_free()
				Projectiles_Spawned.erase(_proj)
				if Projectiles_Spawned.is_empty():
					queue_free()

			"Penetrations":
				penetrations_remaining -= 1
				if penetrations_remaining <= 0:
					_proj.queue_free()
					Projectiles_Spawned.erase(_proj)
					if Projectiles_Spawned.is_empty():
						queue_free()
				else:
					Load_Decal(_proj.get_position())

			"Ricochetes":
				ricochetes_remaining -= 1
				if ricochetes_remaining <= 0:
					_proj.queue_free()
					Projectiles_Spawned.erase(_proj)
					if Projectiles_Spawned.is_empty():
						queue_free()
				else:
					var normal = (body.global_transform.origin - _proj.global_transform.origin).normalized()
					var new_direction = _proj.linear_velocity.bounce(normal).normalized()
					_proj.set_linear_velocity(new_direction * Projectile_Velocity)
					_proj.global_transform.origin += new_direction * 30 # Ajuste para evitar o "sticking"
					Load_Decal(_proj.get_position())

func apply_knockback(target: Node3D, direction: Vector3, force: float):
	if target.has_method("apply_knockback"):
		target.call("apply_knockback", direction * force)

func _on_timer_timeout():
	queue_free()
