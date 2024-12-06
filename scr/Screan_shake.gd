extends Node

# Variáveis para controlar o shake
var shake_intensity: float = 0.5   # Intensidade do tremor (quanto maior, mais forte o tremor)
var shake_duration: float = 0.5     # Duração do tremor em segundos
var shake_decay: float = 0.1        # Quão rápido o tremor vai diminuir ao longo do tempo

# Armazenando o tempo restante do shake
var shake_timer: float = 0.0
var shake_offset: Vector3 = Vector3.ZERO
var initial_camera_position: Vector3 = Vector3.ZERO  # Armazena a posição inicial da câmera

# Referência para a câmera principal (Camera3D)
@export var camera: Camera3D  # Ajuste conforme o tipo de câmera que está usando

func _ready():
	# Armazena a posição inicial da câmera quando o jogo começa
	initial_camera_position = camera.transform.origin

func _process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta  # Reduz o tempo restante do shake
		
		# Gerar deslocamento aleatório nos três eixos (X, Y, Z)
		shake_offset = Vector3(
			randf_range(-shake_intensity, shake_intensity),  # Deslocamento no eixo X
			0, #randf_range(-shake_intensity, shake_intensity),  # Deslocamento no eixo Y
			randf_range(-shake_intensity, shake_intensity)   # Deslocamento no eixo Z
		)
		
		# Gradualmente diminui a intensidade do shake
		shake_intensity = max(0, shake_intensity - shake_decay * delta)
		
		# Aplica o shake à posição da câmera (deslocamento)
		camera.transform.origin = initial_camera_position + shake_offset
	else:
		# Quando o tremor acabar, restaura a posição original da câmera
		camera.transform.origin = initial_camera_position

func start_screen_shake(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
	shake_decay = intensity / duration  # Ajuste a desaceleração do shake de acordo com a intensidade e duração
