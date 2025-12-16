extends CharacterBody3D

# Variables configurables
@export var hp = 30
@export var speed = 4.0
@export var xp_reward = 20

# --- NUEVA VARIABLE PARA LA EXPLOSIÓN ---
@export var explosion_scene: PackedScene 

func _ready():
	# Aumentar vida según dificultad del nivel actual
	hp += ArenaJuego.get_enemy_hp_bonus()

func _physics_process(delta):
	# Si el jugador existe, perseguirlo
	if ArenaJuego.player_ref:
		var direction = (ArenaJuego.player_ref.global_position - global_position).normalized()
		velocity = direction * speed
		look_at(ArenaJuego.player_ref.global_position, Vector3.UP)
		
		move_and_slide()
		
		# Detectar choque con el jugador (Game Over)
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if col.get_collider().is_in_group("player"):
				ArenaJuego.end_game()

# Función para recibir daño de las balas
func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()

# Función de muerte
func die():
	# --- PARTE NUEVA: INSTANCIAR EXPLOSIÓN ---
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		# Lo añadimos al "mundo" (get_parent), no al enemigo, porque el enemigo se va a borrar
		get_parent().add_child(explosion)
		explosion.global_position = global_position
	
	# Dar experiencia y desaparecer
	ArenaJuego.add_xp(xp_reward)
	queue_free()