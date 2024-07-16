extends Label

var moving = false
var speed_x = 0
var speed_y = 0

var starting_position = global_position


func _process(delta):
	if moving:
		global_position.x += speed_x
		global_position.y += speed_y

func showFloatingLabel(value, color, x_speed, y_speed, duration):
	moveFloatingLabel(x_speed, y_speed, duration)
	text = str(value)
	self_modulate = color
	show()

func hideFloatingLabel():
	hide()
	global_position = starting_position

func moveFloatingLabel(new_speed_x, new_speed_y, duration):
	if not moving:
		moving = true
		speed_x = new_speed_x
		speed_y = new_speed_y
		await get_tree().create_timer(duration).timeout
		hideFloatingLabel()
		moving = false
