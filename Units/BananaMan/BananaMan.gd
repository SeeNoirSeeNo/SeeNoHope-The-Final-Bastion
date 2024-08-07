extends Unit

var critical_strike_scene = preload("res://UnitSkills/CriticalStrike/CriticalStrike.tscn")

func _init():
	has_crit = true
	has_lifeleech = true
	has_miss = true

func _ready():
	super()

func end_of_turn_action():
	pass
