extends Unit

var lifeleech_scene = preload("res://UnitSkills/LifeLeech/LifeLeech.tscn")

func _init():
	pass

func _ready():
	super()
	var lifeleech = lifeleech_scene.instantiate()
	skills.add_child(lifeleech)
