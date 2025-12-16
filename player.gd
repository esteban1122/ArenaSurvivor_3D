extends CharacterBody3D

@export var speed = 8.0
@export var bullet_scene: PackedScene 

var attack_timer = 0.0

func _ready():
	ArenaJuego.register_player(self)

func _physics_process(delta):
	# Movimiento
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if direction:
		velocity = direction * speed
		look_at(position + direction, Vector3.UP)
	else:
		velocity = Vector3.ZERO
	move_and_slide()

	# Disparo Automático usando Stats Globales
	attack_timer += delta
	if attack_timer >= ArenaJuego.stats["attack_speed"]: # Usamos velocidad global
		_auto_fire()
		attack_timer = 0.0

func _auto_fire():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty(): return
	
	# Buscar enemigo más cercano
	var closest = enemies[0]
	var min_dist = global_position.distance_to(closest.global_position)
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy
			
	# DISPARO MÚLTIPLE (Bucle for)
	if bullet_scene:
		# Repetimos tantas veces como diga "bullet_count"
		for i in range(ArenaJuego.stats["bullet_count"]):
			var bullet = bullet_scene.instantiate()
			get_parent().add_child(bullet)
			
			# Pequeña separación para que no salgan pegadas
			var offset = Vector3(0, 0, 0)
			if i > 0:
				offset = Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5))
			
			bullet.global_position = global_position + offset
			bullet.direction = (closest.global_position - global_position).normalized()
			
			# ¡ASIGNAR DAÑO A LA BALA!
			bullet.damage = ArenaJuego.stats["damage"]