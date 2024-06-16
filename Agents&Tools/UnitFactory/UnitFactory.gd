extends Node

class_name UnitFactory
### SIGNALS ###
signal unit_created(unit: Unit)
### @EXPORTS ###
### @ONREADY ###
@onready var navigation_grid : NavigationGrid = $"../NavigationGrid"
@onready var map = $"../../Map"
### VARIABLES ###
var possible_units = ["FlyingEye", "CaveGoblin"]
var tile_map : TileMap
var unit_group : Array[PackedScene]

### FUNCTIONS ###


func create_unit(type: String, position: Vector2i, parent: String, group: String, is_cell: bool):
	
	var unit_scene = get_unit_scene(type) #Load the matching scene for the unit type
	var unit = unit_scene.instantiate() #Instantiate the packed scene
	var parent_node = match_parent(parent) #Find the parent
	parent_node.add_child(unit) #Add the Unit as a Child of the given Parent

	#Handle the positioning of the new unit
	var cell
	if is_cell:
		cell = position
	else:
		cell = tile_map.local_to_map(position)
	unit.current_cell = cell
	unit.global_position = tile_map.map_to_local(cell)
	unit.group = group
	#Send the unit created signal
	emit_signal("unit_created", unit)
#	print("UnitFactory: signal unit_created send!")
	
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


#Get The Reference to the Tile Map
func _on_map_loaded(_map_name):
	tile_map = map.get_child(0)
	
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
