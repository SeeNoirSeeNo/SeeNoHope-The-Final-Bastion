extends Unit

var lifeleech_scene = preload("res://UnitSkills/LifeLeech/LifeLeech.tscn")

func _init():
	has_crit = true
	has_lifeleech = true
	has_miss = true

func _ready():
	super()
	var lifeleech = lifeleech_scene.instantiate()
	skills.add_child(lifeleech)
