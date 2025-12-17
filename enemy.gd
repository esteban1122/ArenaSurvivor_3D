extends CharacterBody3D

# Variables configurables
@export var hp = 30
@export var speed = 4.0
@export var xp_reward = 20

# --- NUEVA VARIABLE PARA LA EXPLOSIÓN ---
@export var explosion_scene: PackedScene
@export var hurt_sound: AudioStream
@export var death_sound: AudioStream

var audio_player: AudioStreamPlayer

func _ready():
	# Aumentar vida según dificultad del nivel actual
	hp += ArenaJuego.get_enemy_hp_bonus()
	
	# Crear nodo de audio para enemigo
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = -5

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
	
	# Reproducir sonido de daño
	if audio_player and hurt_sound:
		audio_player.stream = hurt_sound
		audio_player.play()
	
	if hp <= 0:
		die()

# Función de muerte
func die():
	# Reproducir sonido de muerte/explosión
	if audio_player and death_sound:
		audio_player.stream = death_sound
		audio_player.play()
		# Esperar a que termine el sonido antes de desaparecer
		await get_tree().create_timer(death_sound.get_length()).timeout
	
	# --- PARTE NUEVA: INSTANCIAR EXPLOSIÓN ---
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		# Lo añadimos al "mundo" (get_parent), no al enemigo, porque el enemigo se va a borrar
		get_parent().add_child(explosion)
		explosion.global_position = global_position
	
	# Dar experiencia y desaparecer
	ArenaJuego.add_xp(xp_reward)
	queue_free()