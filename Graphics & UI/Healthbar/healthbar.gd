extends TextureProgressBar

@onready var value_label : Label = $ValueLabel
@onready var floating_label = $FloatingLabel


func update(target_unit : Unit):
	value_label.text = str(target_unit.current_health_points)
	value = target_unit.current_health_points * 100 / target_unit.health_points

func showFloatingLabel(value, color):
	floating_label.showFloatingLabel(value, color, 1, -0.5, 0.75)
	
func hideFloatingLabel():
	floating_label.hideFloatingLabel()
