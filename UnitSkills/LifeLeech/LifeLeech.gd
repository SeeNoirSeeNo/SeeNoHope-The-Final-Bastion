extends BaseSkill

func lifeleech(attacker, target, damage, chance, multiplier):
	if randi() <= chance:
		var heal = (damage * multiplier) / 100
		attacker.self_heal(heal, heal)
