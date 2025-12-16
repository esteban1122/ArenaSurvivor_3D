extends GPUParticles3D

func _ready():
	# Aseguramos que empiece a explotar apenas aparece
	emitting = true 
	
	# Esperamos a que termine la animación de las partículas
	await finished
	
	# Eliminamos el nodo para liberar memoria
	queue_free()