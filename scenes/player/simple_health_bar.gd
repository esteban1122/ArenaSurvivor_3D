# simple_health_bar.gd
extends Node2D

@export var max_health: int = 100
var current_health: int = 100
var bar_width: int = 60
var bar_height: int = 8
var bar_offset_y: int = -40

func _ready():
	current_health = max_health
	z_index = 100

func _draw():
	var bar_position = Vector2(-bar_width / 2, bar_offset_y)
	
	# Fondo negro
	draw_rect(Rect2(bar_position, Vector2(bar_width, bar_height)), Color(0, 0, 0, 0.8))
	
	# Barra de vida con color según porcentaje
	var health_percent = float(current_health) / float(max_health)
	var current_bar_width = bar_width * health_percent
	
	var bar_color: Color
	if health_percent > 0.6:
		bar_color = Color(0.2, 1.0, 0.2) # Verde
	elif health_percent > 0.3:
		bar_color = Color(1.0, 1.0, 0.2) # Amarillo
	else:
		bar_color = Color(1.0, 0.2, 0.2) # Rojo
	
	draw_rect(Rect2(bar_position, Vector2(current_bar_width, bar_height)), bar_color)
	
	# Borde
	draw_rect(Rect2(bar_position, Vector2(bar_width, bar_height)), Color(1, 1, 1, 0.5), false, 1.0)

func update_health(new_health: int, new_max_health: int = -1):
	current_health = new_health
	if new_max_health > 0:
		max_health = new_max_health
	queue_redraw()
