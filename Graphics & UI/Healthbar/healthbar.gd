extends TextureProgressBar

@onready var value_label : Label = $ValueLabel
@onready var floating_label_scene = preload("res://Graphics & UI/FloatingLabel/FloatingLabel.tscn")

func update(target_unit : Unit):
	value_label.text = str(target_unit.current_health_points)
	value = target_unit.current_health_points * 100 / target_unit.health_points

func create_floating_label(value, color: Color, velocity: Vector2, duration: float):
	var label_instance = floating_label_scene.instantiate()
	add_child(label_instance)
	label_instance.global_position = self.global_position
	label_instance.start_floating_label(value, color, velocity, duration)
