extends TextureProgressBar

func _on_timeline_updated(timeline):
	var combined_max_hp : int = 0
	for unit in timeline:
		combined_max_hp += unit.health_points
	max_value = combined_max_hp

	var combined_player_hp : int = 0
	for unit in timeline:
		if unit.group == "Player":
			combined_player_hp += unit.current_health_points
	value = combined_player_hp

