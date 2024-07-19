extends TextureProgressBar


func _on_timeline_updated(timeline):
	var combined_max_tu : int = 0
	for unit in timeline:
		combined_max_tu += unit.timeunits
	max_value = combined_max_tu

	var combined_tu : int = 0
	for unit in timeline:
		combined_tu += unit.current_timeunits
	value = combined_tu
