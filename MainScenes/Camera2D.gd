# In Camera2D script
extends Camera2D

var speed = 500  # Speed of camera movement in pixels per second
var zoom_speed = 0.1  # Speed of zooming

func _process(delta):
	var direction = Vector2()
	if Input.is_action_pressed("Right"):
		direction.x += 1
	if Input.is_action_pressed("Left"):
		direction.x -= 1
	if Input.is_action_pressed("Down"):
		direction.y += 1
	if Input.is_action_pressed("Up"):
		direction.y -= 1
	position += direction.normalized() * speed * delta

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += Vector2(zoom_speed, zoom_speed)
