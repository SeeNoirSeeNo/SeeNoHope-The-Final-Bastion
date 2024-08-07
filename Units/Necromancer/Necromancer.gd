extends Unit

func _init():
	has_crit = true
	has_lifeleech = true
	has_miss = true


func end_of_turn_action():
	regen()
