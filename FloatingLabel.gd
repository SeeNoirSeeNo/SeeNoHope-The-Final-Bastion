extends Label

var moving = false
var speed_x = 0
var speed_y = 0

func start_floating_label(value, color, velocity, duration):
	var tween = create_tween()
	tween.tween_property(self, "global_position", global_position + velocity, duration)
	text = str(value)
	self_modulate = color
	show()
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(self._on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	queue_free()
