extends Area3D

var speed = 20.0
var direction = Vector3.FORWARD
var damage = 10 # <--- ESTA VARIABLE ES OBLIGATORIA

func _physics_process(delta):
	position += direction * speed * delta

# Detectar choque con enemigo
func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage) # Usamos el daño que nos dio el jugador
		queue_free() # Destruir bala