extends RichTextLabel

@onready var timer: Timer = $Timer


var total_time = 600  # 10 minutos em segundos

func _ready() -> void:
	timer.start(1.0)  # Inicia o timer com intervalos de 1 segundo
	update_time_display()


func _on_timer_timeout():
	if total_time > 0:
		total_time -= 1
		update_time_display()
	else:
		timer.stop()  # Para o timer quando o tempo chega a zero

func update_time_display():
	var minutes = int(total_time / 60)
	var seconds = int(total_time % 60)
	
	var minute_str = str(minutes).pad_zeros(2)
	var second_str = str(seconds).pad_zeros(2)
	
	#set_text(" " + minute_str + ":" + second_str)
	text = str(" " + minute_str + ":" + second_str)
