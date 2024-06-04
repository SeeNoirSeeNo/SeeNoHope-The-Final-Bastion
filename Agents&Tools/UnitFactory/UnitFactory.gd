extends Node

class_name UnitFactory
### SIGNALS ###
### @EXPORTS ###
### @ONREADY ###
@onready var navigation_grid = $"../NavigationGrid"
@onready var map = $"../../Map"
### VARIABLES ###
var possible_units = ["FlyingEye", "CaveGoblin"]
var tile_map : TileMap
var unit_group : Array[PackedScene]

### FUNCTIONS ###

func _on_map_loaded(_map_name):
	tile_map = map.get_child(0)

#func spawn_group():
#	for unit in unit_group:
#		var position = map.get_random_available_cell()
#		create_unit(unit, position, get_node("/root/Battle/Units/Enemy"), "enemy")


#func add_unit_to_group(type, amount):
#	var unit_scene = get_unit_scene(type)
#	for number in amount:
#		unit_group.append(unit_scene)





#CREATES A NEW UNIT
# Spawns a group of units.
# `unit_type` is the type of units to spawn.
# `position` is the position at which to spawn the units.5
func create_unit(type: String, position: Vector2i, parent: String, group: String):
	
	var unit_scene = get_unit_scene(type) #Load the matching scene for the unit type
	var unit = unit_scene.instantiate() #Instantiate the packed scene
	var parent_node = match_parent(parent)
	parent_node.add_child(unit) #Add the Unit as a Child of the given Parent

	var grid_position = tile_map.local_to_map(position)
	unit.global_position = tile_map.map_to_local(grid_position)#5 + Vector2(16, 16)

	unit.add_to_group(group) #Add the Unit to the correct group

func get_unit_scene(type: String):
	#Load the matching scene for the unit type
	var unit_scene : PackedScene
	match type:
		"FlyingEye":
			unit_scene = load("res://Units/FlyingEye/FlyingEye.tscn")
		"CaveGoblin":
			unit_scene = load("res://Units/CaveGoblin/CaveGoblin.tscn")
		_:
			printerr("Invalid unit type")
			return null	
	return unit_scene

func match_parent(parent) -> Node:
	var parent_node : Node
	match parent:
		"Enemy":
			parent_node = $"../../Units/Enemy"
		"Player":
			parent_node = $"../../Units/Player"
		"Neutral":
			parent_node = $"../../Units/Neutral"
		_:
			printerr("Invalid parent type")
	return parent_node

		
#func _input(event):
#	if event.is_action_pressed("unit"):
#		spawn_unit()

#func spawn_unit():
#	var type = possible_units[randi() % possible_units.size()] # Choose a random unit type
#	print("UnitFactory: type = ", type)
#	var position = get_viewport().get_mouse_position() # Get the current mouse position
#	print("UnitFactory: position = ", position)
#	var possible_parents = [get_node("/root/Battle/Units/Enemy"), get_node("/root/Battle/Units/Player"), get_node("/root/Battle/Units/Neutral")] # Define the possible parents
#	var parent = possible_parents[randi() % possible_parents.size()] # Choose a random parent
#	print("UnitFactory: parent = ", parent)
#	var groups = ["Enemy", "Player", "Natural"] # Define the possible groups
#	var group = groups[randi() % groups.size()] # Choose a random group
#	print("UnitFactory: group = ", group)
#	create_unit(type, position, parent, group)
