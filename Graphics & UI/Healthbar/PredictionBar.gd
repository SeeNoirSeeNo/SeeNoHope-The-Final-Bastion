extends TextureProgressBar
@onready var player_hp = $PlayerHP
@onready var enemy_hp = $EnemyHP

func _on_timeline_updated(timeline):
	var combined_max_hp : int = 0
	for unit in timeline:
		combined_max_hp += unit.health_points
	max_value = combined_max_hp

	var combined_player_hp : int = 0
	var combined_enemy_hp : int = 0
	for unit in timeline:
		if unit.group == "Player":
			combined_player_hp += unit.current_health_points
		elif unit.group == "Enemy":
			combined_enemy_hp += unit.current_health_points
			
	value = combined_player_hp
	player_hp.text = str(combined_player_hp)
	enemy_hp.text = str(combined_enemy_hp)
