# player.gd

extends CharacterBody2D

@export var speed: float = 150.0
@export var fire_rate: float = 0.5
@export var bullet_scene: PackedScene
@export var max_health: int = 100
@export var game_over_scene: PackedScene
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var health_bar
var hud: Node
var last_direction: Vector2 = Vector2.RIGHT
var current_health: int
var can_take_damage: bool = true
var is_dead: bool = false

var survival_time: float = 0.0
var kill_count: int = 0

var shield_count: int = 0
var max_shields: int = 3
var rapid_fire_active: bool = false
var rapid_fire_timer: float = 0.0
var base_fire_rate: float = 0.5

func _ready():
	current_health = max_health
	is_dead = false
	can_take_damage = true
	survival_time = 0.0
	kill_count = 0
	base_fire_rate = fire_rate
	
	set_physics_process(true)
	set_process(true)
	
	animated_sprite.play("idle")
	
	if not is_in_group("player"):
		add_to_group("player")
	
	create_health_bar()
	call_deferred("find_hud")

func find_hud():
	hud = get_tree().get_first_node_in_group("hud")
	if hud:
		print("HUD encontrado")
		if hud.has_method("update_health"):
			hud.update_health(current_health, max_health)

func _process(delta):
	if not is_dead:
		survival_time += delta
		if hud and hud.has_method("update_time"):
			hud.update_time(survival_time)
	
	if rapid_fire_active:
		rapid_fire_timer -= delta
		if rapid_fire_timer <= 0:
			rapid_fire_active = false
			fire_rate = base_fire_rate
			if hud and hud.has_method("update_rapid_fire"):
				hud.update_rapid_fire(false)

func _physics_process(_delta):
	if is_dead:
		return
		
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		last_direction = input_vector
	
	velocity = input_vector * speed
	
	if velocity.length() > 0:
		animated_sprite.play("run")
		if velocity.x > 0:
			animated_sprite.flip_h = false
		elif velocity.x < 0:
			animated_sprite.flip_h = true
	else:
		if animated_sprite.animation != "receivedamage":
			animated_sprite.play("idle")
	
	move_and_slide()

func _on_fire_timer_timeout():
	if bullet_scene == null or is_dead:
		return
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		return
	
	var closest_enemy = enemies[0]
	var min_distance = global_position.distance_to(closest_enemy.global_position)
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_enemy = enemy
	
	var shoot_direction = (closest_enemy.global_position - global_position).normalized()
	
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.set_direction(shoot_direction)
	
	if SoundManager and SoundManager.has_method("play_sound"):
		SoundManager.play_sound("shoot", -10.0)

func take_damage(amount: int):
	if not can_take_damage or is_dead:
		return
	
	if shield_count > 0:
		shield_count -= 1
		if hud and hud.has_method("update_shields"):
			hud.update_shields(shield_count)
		print("Escudo usado")
		return
	
	current_health -= amount
	current_health = max(0, current_health)
	
	if health_bar:
		health_bar.update_health(current_health, max_health)
	
	if hud and hud.has_method("update_health"):
		hud.update_health(current_health, max_health)
	
	if current_health <= 0:
		die()
	else:
		can_take_damage = false
		if has_node("TimerIFrames"):
			$TimerIFrames.start()
		else:
			var timer = get_tree().create_timer(1.0)
			timer.timeout.connect(func(): can_take_damage = true)
		
		if animated_sprite.sprite_frames.has_animation("receivedamage"):
			animated_sprite.play("receivedamage")

func _on_hurtbox_body_entered(body):
	if body.is_in_group("enemy") and not is_dead and can_take_damage:
		# Solo tomar daño si el hurtbox puede recibir daño
		var damage_amount = 10
		if body.get("damage"):
			damage_amount = body.damage
		take_damage(damage_amount)

func _on_timer_i_frames_timeout():
	can_take_damage = true

func die():
	if is_dead:
		return
	
	is_dead = true
	print("Jugador muerto")
	
	velocity = Vector2.ZERO
	set_physics_process(false)
	
	if animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	else:
		await get_tree().create_timer(0.5).timeout
	
	show_game_over()

func show_game_over():
	get_tree().paused = true
	
	if game_over_scene == null:
		game_over_scene = load("res://scenes/ui/GameOver.tscn")
		if game_over_scene == null:
			print("No se pudo cargar GameOver")
			return
	
	var game_over = game_over_scene.instantiate()
	get_tree().root.add_child(game_over)
	
	await get_tree().process_frame
	
	if game_over.has_method("set_stats"):
		game_over.set_stats(survival_time, kill_count)

func add_kill():
	kill_count += 1
	if hud and hud.has_method("update_kills"):
		hud.update_kills(kill_count)

func create_health_bar():
	var health_bar_script = load("res://scenes/player/simple_health_bar.gd")
	if health_bar_script:
		health_bar = Node2D.new()
		health_bar.set_script(health_bar_script)
		health_bar.max_health = max_health
		add_child(health_bar)
		health_bar.update_health(current_health, max_health)

func activate_red_power():
	if is_dead:
		return
	# Restaurar HP aleatoriamente entre 4 y 10
	var heal_amount = randi_range(10, 30)
	current_health += heal_amount
	if current_health > max_health:
		current_health = max_health
	
	# Actualizar ambas barras
	if health_bar and health_bar.has_method("update_health"):
		health_bar.update_health(current_health, max_health)
	if hud and hud.has_method("update_health"):
		hud.update_health(current_health, max_health)
	
	print("❤️ Esfera roja: +", heal_amount, " HP | Salud actual: ", current_health)

func activate_silver_power():
	if is_dead:
		return
	if shield_count < max_shields:
		shield_count += 1
		if hud and hud.has_method("update_shields"):
			hud.update_shields(shield_count)

func activate_yellow_power():
	if is_dead:
		return
	rapid_fire_active = true
	rapid_fire_timer = 5.0
	fire_rate = base_fire_rate * 0.3
	if hud and hud.has_method("update_rapid_fire"):
		hud.update_rapid_fire(true)
