extends CharacterBody2D

class_name Unit

### SIGNALS ###
signal turn_finished()
### @EXPORT ###
### @ONREADY ###
@onready var map = $"../../../Map".get_child(0)
@onready var navigation_grid : NavigationGrid = $"../../../Agents/NavigationGrid"
@onready var path_line = $"../../../Agents/NavigationGrid/PathIndicator"
### VARIABLES ###
var active_path: Array[Vector2i]
var current_cell : Vector2i
var adjacent_cells : Dictionary


@export var unit_type : String

@export var speed : int
@export var time_units : int
var current_time_units : int
var is_done_for_the_round : bool = false

@export var health_points : int
var current_health_points : int

var attack_range : int = 1
var actions : Dictionary = { "move" : 9, "attack" : 40}
var group : String

var is_active : bool = false



### FUNCTIONS ###

func _ready():
	await get_tree().process_frame #HACK: Wait so everything is init correctly and does not crash...
	initiliaze_variables()
	add_to_group(group) #Add the Unit to the correct group
#	choose_action()

func _physics_process(_delta):
	set_destination_LMB() #Calc new path to location of LMB
	move_along_path() ##HERE IT WORKS WTF

func _draw():
	if is_active:
		draw_circle(Vector2.ZERO, 15, Color.RED)

func set_active(active : bool) -> void:
	is_active = active
	queue_redraw()
		
#func start_turn():
#	choose_action()

func print_if_active(args: Array):
	if is_active:
		print(args)


#Init child variables -> ._ready() might be needed later
func initiliaze_variables():
	add_to_group(group) #Add the Unit to the correct group
	current_cell = navigation_grid.get_cell(global_position) #Save where the unit is
#	adjacent_cells = navigation_grid.get_adjacent_cells(current_cell) #Save cells next to this unit
	current_health_points = health_points
	current_time_units = time_units

func choose_action():
	current_cell = navigation_grid.get_cell(global_position)
	adjacent_cells = navigation_grid.get_adjacent_cells(current_cell) #Update
	if time_units >= actions["attack"] && is_enemy_near():
		var near_units = navigation_grid.get_adjacent_units(self, group)
		print_if_active(["Unit Type: ", unit_type, " I could attack any of those enemies!: ", near_units])
	elif time_units >= actions["move"] && not is_enemy_near():
		set_path_to_next_enemy()
		pay_for_movement()
		update_path_line()
		move_along_path()
		#print("I finished my turn yooo")
		#emit_signal("turn_finished")



func set_path_to_next_enemy():
	var destination = navigation_grid.get_closest_unit_cell(self, group)
	active_path = navigation_grid.astar.get_id_path(current_cell, destination)
	print_if_active(["Unit Type: ", unit_type, " I want to move to this cell: ", destination, " using this path: ", active_path])


func pay_for_movement():
	print_if_active(["time_units: ", current_time_units])
	var cells_to_move = min(current_time_units / actions["move"], active_path.size())
	print_if_active(["Cells to move: ", cells_to_move])
	current_time_units -= cells_to_move * actions["move"]
	print_if_active(["Current time units after paying for movement: ", current_time_units])
	active_path = active_path.slice(0, int(cells_to_move))
	print_if_active(["My Active Path after paying for movement: ", active_path])

func move_along_path():
	if active_path.is_empty():
	#?#	print_if_active(["Active path is empty"])
		return
		
	var target_position = map.map_to_local(active_path.front())
	print_if_active(["Target position: ", target_position])

	global_position = global_position.move_toward(target_position, speed)
	navigation_grid.move_unit(self, target_position) #Frees the cell
	
	if global_position == target_position:
		active_path.pop_front()
		path_line.remove_point(0)
		print_if_active(["Active path after moving: ", active_path])



func refill_time_units():
	current_time_units = time_units
func is_enemy_near() -> bool:
	return navigation_grid.get_adjacent_units(self, group).size() > 0
func get_my_cell():
	current_cell = navigation_grid.get_cell(global_position)
func get_adjacent_cells():
	adjacent_cells = navigation_grid.get_adjacent_cells(current_cell)



###Sets the new destination to where LMB was clicked###
#Check if Input was LMB
func set_destination_LMB():
	var event = Input
	if event.is_action_pressed("move") == false:
		return
#	choose_action()

func update_path_line():
	path_line.clear_points()
	for point in active_path:
		path_line.add_point(map.map_to_local(point))
