extends Node2D

var unit_types = UnitList.get_possible_units()

# Dictionaries to keep track of killed units
var enemy_units_killed = {}
var player_units_killed = {}


func _ready():
	reset_killed_units()

# Resets the Killed Units to 0
func reset_killed_units():
	for unit_type in unit_types:
		enemy_units_killed[unit_type] = 0
		player_units_killed[unit_type] = 0

func get_killed_units(team, unit_type):
	if team == "Player":
		return player_units_killed.get(unit_type, 0)
	elif team == "Enemy":
		return player_units_killed.get(unit_type, 0)
	else:
		return "BattleData->get_killed_units: INVALID TEAM"
