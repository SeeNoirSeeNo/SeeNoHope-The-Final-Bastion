extends CharacterBody2D

class_name BaseUnit

### SIGNALS ###
### @EXPORT ###
### @ONREADY ###
@onready var map = $"../../../Map".get_child(0)
@onready var navigation_grid = $"../../../Agents/NavigationGrid"
@onready var path_line = $"../../../Agents/NavigationGrid/PathIndicator"
### VARIABLES ###
var active_path: Array[Vector2i]
var speed = 2

### FUNCTIONS ###
func _physics_process(_delta):
	set_destination_LMB() #Calc new path to location of LMB
	move_along_path() #Move towards the next point of active path

###Sets the new destination to where LMB was clicked###
#Check if Input was LMB
func set_destination_LMB():
	var event = Input
	if event.is_action_pressed("move") == false:
		return

	#If LMB was clicked, translate position to grid coords
	var new_path = navigation_grid.astar.get_id_path(
		map.local_to_map(global_position),
		map.local_to_map(get_global_mouse_position())
	)
	#If the new path is not empty, set it as the current path
	if new_path.is_empty() == false:
		active_path = new_path
		#If we have a path, draw the line
		update_path_line()

func update_path_line():
	path_line.clear_points()
	for point in active_path:
		path_line.add_point(map.map_to_local(point))

func move_along_path():
	if active_path.is_empty():
		return

	var target_position = map.map_to_local(active_path.front())

	global_position = global_position.move_toward(target_position, speed)
	
	if global_position == target_position:
		active_path.pop_front()
		path_line.remove_point(0)
