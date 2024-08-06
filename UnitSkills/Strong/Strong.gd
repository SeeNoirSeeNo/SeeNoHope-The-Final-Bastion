extends BaseSkill

var damage_increase : int = 100

func adjust_base_damage(caller, base_damage):
	caller.base_damage += damage_increase

func adjust_base_damage2(caller, base_damage):
	var new_base_damage = base_damage + damage_increase
	return new_base_damage
