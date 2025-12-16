extends Node3D

@export var enemy_scene: PackedScene 

func _ready():
	# Conectar el reloj
	$EnemySpawner/Timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	# Si no hay jugador o enemigo configurado, no hacer nada
	if not enemy_scene or not ArenaJuego.player_ref:
		return
		
	var enemy = enemy_scene.instantiate()
	
	# Posición aleatoria alrededor del jugador
	var angle = randf() * PI * 2
	var distance = 15.0
	var spawn_pos = ArenaJuego.player_ref.global_position
	
	spawn_pos.x += cos(angle) * distance
	spawn_pos.z += sin(angle) * distance
	
	enemy.global_position = spawn_pos
	add_child(enemy)