extends TextureProgressBar

@onready var value_label : Label = $ValueLabel


func update(target_unit: Unit):
	value_label.text = str(target_unit.current_timeunits)
	value = target_unit.current_timeunits * 100 / target_unit.timeunits
