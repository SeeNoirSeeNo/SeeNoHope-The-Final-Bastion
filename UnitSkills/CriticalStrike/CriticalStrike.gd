#CriticalStrike
extends BaseSkill

func apply_skill(caller):
	caller.has_crit = true
	
func crit(attacker, target, damage):
	if randf() * 100 <= attacker.crit_chance:
		var min_crit = attacker.base_min_damage * attacker.crit_multiplier
		var max_crit = attacker.base_max_damage * attacker.crit_multiplier
		damage = randi_range(min_crit, max_crit)
		attacker.crit_flag = true
		print(attacker.crit_flag)
		return damage
	else:
		return damage
