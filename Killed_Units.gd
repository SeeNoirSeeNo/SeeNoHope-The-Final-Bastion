extends Control
@onready var player_units = $PlayerUnits
@onready var enemy_units = $EnemyUnits

#WIP
func _process(delta):
	player_units.text = BattleData.player_units_killed
	enemy_units.text = BattleData.player_units_killed
