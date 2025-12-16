extends Node

# --- SEÑALES ---
signal xp_gained(current_xp, max_xp)
signal level_up(new_level)
signal game_over

# --- VARIABLES DE JUEGO ---
var level = 1
var current_xp = 0
var max_xp = 100
var player_ref: Node3D = null

# --- ESTADÍSTICAS DEL JUGADOR (Modo Dificil: Empiezas débil) ---
var stats = {
	"damage": 5,        # Daño bajo al inicio (necesitas varios tiros)
	"bullet_count": 1,  # 1 sola bala
	"attack_speed": 0.8 # Disparo lento (casi 1 segundo entre balas)
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Funciona con el juego pausado
	setup_controls()
	print("ArenaJuego listo. Dificultad: RETO.")

# --- SISTEMA DE MEJORAS (Suben poco a poco) ---
func apply_upgrade(upgrade_type):
	match upgrade_type:
		"damage":
			stats["damage"] += 2 # Solo sube +2 de daño (tienes que mejorar mucho)
			print("¡Mejora! Daño: ", stats["damage"])
		"multishot":
			stats["bullet_count"] += 1
			print("¡Mejora! Balas: ", stats["bullet_count"])
		"speed":
			stats["attack_speed"] *= 0.9 # Dispara un 10% más rápido
			if stats["attack_speed"] < 0.1: stats["attack_speed"] = 0.1
			print("¡Mejora! Velocidad: ", stats["attack_speed"])

# --- DIFICULTAD ENEMIGOS (Escalado de vida) ---
func get_enemy_hp_bonus():
	# Nivel 1: +0 HP
	# Nivel 2: +15 HP
	# Nivel 10: +135 HP
	return (level - 1) * 15

# --- LÓGICA GENERAL ---
func register_player(player):
	player_ref = player

func end_game():
	get_tree().paused = true
	emit_signal("game_over")

func add_xp(amount):
	current_xp += amount
	emit_signal("xp_gained", current_xp, max_xp)
	
	if current_xp >= max_xp:
		level += 1
		current_xp = 0
		max_xp = int(max_xp * 1.5) # Cada nivel pide 50% más XP
		emit_signal("level_up", level)
		get_tree().paused = true # Pausa para elegir poder

# --- CONTROLES AUTOMÁTICOS ---
func setup_controls():
	var inputs = {
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT]
	}
	for action in inputs:
		if not InputMap.has_action(action): InputMap.add_action(action)
		InputMap.action_erase_events(action)
		for k in inputs[action]:
			var ev = InputEventKey.new()
			ev.physical_keycode = k
			InputMap.action_add_event(action, ev)