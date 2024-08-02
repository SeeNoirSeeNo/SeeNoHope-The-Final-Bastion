extends Unit


var self_heal_min = 10
var self_heal_max = 20
var critical_strike_scene = preload("res://UnitSkills/CriticalStrike/CriticalStrike.tscn")

func _init():
	pass

func _ready():
	super()
	var critical_strike = critical_strike_scene.instantiate()
	skills.add_child(critical_strike)
	print("CRIT ADDEDED", self)
	
func end_of_turn_action():
	self_heal(self_heal_min, self_heal_max)
	var test = true
