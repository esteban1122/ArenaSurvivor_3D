extends CanvasLayer

# Referencias a las cajas y el fondo
@onready var game_over_box = $GameOverBox
@onready var level_up_box = $LevelUpBox
@onready var background = $FondoNegro

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Para que funcione durante la pausa
	
	# Ocultamos todo al arrancar
	background.visible = false
	game_over_box.visible = false
	level_up_box.visible = false
	
	# Conectar señales del cerebro (ArenaJuego)
	ArenaJuego.game_over.connect(mostrar_game_over)
	ArenaJuego.level_up.connect(mostrar_level_up)
	
	# --- CONECTAR BOTONES ---
	# Botón de Game Over
	$GameOverBox/Button.pressed.connect(reiniciar)
	
	# Botones de Poderes (Aquí usamos los nombres que acabas de poner)
	$LevelUpBox/BtnDamage.pressed.connect(func(): aplicar("damage"))
	$LevelUpBox/BtnMulti.pressed.connect(func(): aplicar("multishot"))
	$LevelUpBox/BtnSpeed.pressed.connect(func(): aplicar("speed"))

# --- FUNCIONES VISUALES ---

func mostrar_game_over():
	background.visible = true
	game_over_box.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func mostrar_level_up(nivel):
	background.visible = true
	level_up_box.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Actualizamos el texto de los botones con los valores actuales
	$LevelUpBox/BtnDamage.text = "+ FUERZA (Nivel actual: " + str(ArenaJuego.stats["damage"]) + ")"
	$LevelUpBox/BtnMulti.text = "+ DOBLE CAÑÓN (Balas: " + str(ArenaJuego.stats["bullet_count"]) + ")"
	$LevelUpBox/BtnSpeed.text = "+ AMETRALLADORA (Vel: " + str(ArenaJuego.stats["attack_speed"]) + ")"

func aplicar(tipo):
	# Mandamos la mejora al cerebro
	ArenaJuego.apply_upgrade(tipo)
	# Ocultamos menú y seguimos jugando
	background.visible = false
	level_up_box.visible = false
	get_tree().paused = false

func reiniciar():
	get_tree().paused = false
	# Reseteamos valores
	ArenaJuego.level = 1
	ArenaJuego.current_xp = 0
	ArenaJuego.max_xp = 100
	ArenaJuego.stats = {"damage": 10, "bullet_count": 1, "attack_speed": 0.5}
	get_tree().reload_current_scene()