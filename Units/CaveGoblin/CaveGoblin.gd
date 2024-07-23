extends Unit


var self_heal_min = 10
var self_heal_max = 20

func _init():
	pass

func end_of_turn_action():
	self_heal(self_heal_min, self_heal_max)
