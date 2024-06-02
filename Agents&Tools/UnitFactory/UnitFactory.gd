extends Node

class_name UnitFactory
### SIGNALS ###
### @EXPORTS ###
### @ONREADY ###
@onready var navigation_grid = $"../NavigationGrid"
@onready var map = $"../../Map"
### VARIABLES ###
var possible_units = ["FlyingEye", "CaveGoblin"]
var tile_map


### FUNCTIONS ###







#CREATES A NEW UNIT
func create_unit(type, position, parent, group):

	var unit_scene : PackedScene
	var unit

#Load the matching scene for the unit type
	match type:
		"FlyingEye":
			unit_scene = load("res://Units/FlyingEye/FlyingEye.tscn")
		"CaveGoblin":
			unit_scene = load("res://Units/CaveGoblin/CaveGoblin.tscn")
		_:
			printerr("Invalid unit type")
			return null

	unit = unit_scene.instantiate() #Instantiate the packed scene
	parent.add_child(unit) #Add the Unit as a Child of the given Parent

	var grid_position = tile_map.local_to_map(position)
	unit.global_position = tile_map.map_to_local(grid_position) + Vector2(16, 16)

	unit.add_to_group(group) #Add the Unit to the correct group

func _input(event):
	if event.is_action_pressed("unit"):
		spawn_unit()

func spawn_unit():
	var type = possible_units[randi() % possible_units.size()] # Choose a random unit type
	print("UnitFactory: type = ", type)
	var position = get_viewport().get_mouse_position() # Get the current mouse position
	print("UnitFactory: position = ", position)
	var possible_parents = [get_node("/root/Battle/Units/Enemy"), get_node("/root/Battle/Units/Player"), get_node("/root/Battle/Units/Neutral")] # Define the possible parents
	var parent = possible_parents[randi() % possible_parents.size()] # Choose a random parent
	print("UnitFactory: parent = ", parent)
	var groups = ["Enemy", "Player", "Natural"] # Define the possible groups
	var group = groups[randi() % groups.size()] # Choose a random group
	print("UnitFactory: group = ", group)
	create_unit(type, position, parent, group)

func _on_map_loaded(_map_name):
	tile_map = map.get_child(0)
