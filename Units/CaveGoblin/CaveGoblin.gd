extends Unit

var critical_strike_scene = preload("res://UnitSkills/CriticalStrike/CriticalStrike.tscn")



func _init():
	has_crit = true
	has_lifeleech = true
	has_miss = true
### OLD APPROACH WITH SKILL NODES
#func _ready():
	#super()
	#var critical_strike = critical_strike_scene.instantiate()
	#skills.add_child(critical_strike)
	#critical_strike.apply_skill(self)

func end_of_turn_action():
	regen()
	#var test = true
