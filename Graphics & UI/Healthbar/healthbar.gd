extends TextureProgressBar

@onready var value_label : Label = $ValueLabel


func update(target_unit : Unit):
	value_label.text = str(target_unit.current_health_points)
	value = target_unit.current_health_points * 100 / target_unit.health_points
