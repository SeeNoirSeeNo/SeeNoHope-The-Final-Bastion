extends CharacterBody2D

class_name Unit

### SIGNALS ###
signal turn_finished()
signal movement_finished()
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
var actions : Dictionary = { "move" : 15, "attack" : 40}
var group : String

var is_active : bool = false



### FUNCTIONS ###
func _ready():
	await get_tree().process_frame #HACK: Wait so everything is init correctly and does not crash...
	initiliaze_variables()

func _physics_process(_delta):
	move_along_path() ##HERE IT WORKS WTF



func _draw():
	if is_active:
		draw_circle(Vector2.ZERO, 15, Color.RED)

func set_active(active : bool) -> void:
	is_active = active
	queue_redraw()



func start_turn():
	print("I choose my action now")
	choose_action()

#Only the active unit should print the print commands
func print_if_active(args: Array):
	if is_active:
		print(args)


#Init child variables -> ._ready() might be needed later
func initiliaze_variables():
	add_to_group(group) #Add the Unit to the correct group
	current_cell = navigation_grid.get_cell(global_position) #Save where the unit is
	current_health_points = health_points
	current_time_units = time_units

func choose_action():
	current_cell = navigation_grid.get_cell(global_position)
	adjacent_cells = navigation_grid.get_adjacent_cells(current_cell) #Update
	if current_time_units >= actions["attack"] && is_enemy_near():
		var near_units = navigation_grid.get_adjacent_units(self, group)
#		print_if_active(["Unit Type: ", unit_type, " I could attack any of those enemies!: ", near_units])
	elif current_time_units >= actions["move"] && not is_enemy_near():
		set_path_to_next_enemy()
		pay_for_movement()
		update_path_line()
		await movement_finished
		await get_tree().create_timer(2.5).timeout
#		print(self, "I finished my turn yooo")
		emit_signal("turn_finished")
		set_active(false)
	else:
		is_done_for_the_round = true
		print(self, " I am done for the round Yahahahah")
		emit_signal("turn_finished")



func set_path_to_next_enemy():
	var destination = navigation_grid.get_closest_unit_cell(self, group)
	active_path = navigation_grid.astar.get_id_path(current_cell, destination)
#	print_if_active(["Unit Type: ", unit_type, " I want to move to this cell: ", destination, " using this path: ", active_path])


func pay_for_movement():
#	print_if_active(["time_units: ", current_time_units])
	var cells_to_move = min(current_time_units / actions["move"], active_path.size())
#	print_if_active(["Cells to move: ", cells_to_move])
	current_time_units -= cells_to_move * actions["move"]
#	print_if_active(["Current time units after paying for movement: ", current_time_units])
	active_path = active_path.slice(0, int(cells_to_move))
#	print_if_active(["My Active Path after paying for movement: ", active_path])

func move_along_path():
	if active_path.is_empty():
		emit_signal("movement_finished")
		return
		
	var target_position = map.map_to_local(active_path.front())
#	print_if_active(["Target position: ", map.local_to_map(target_position)])

	global_position = global_position.move_toward(target_position, speed)
	navigation_grid.leave_old_cell(self) #Frees the cell
	if global_position == target_position:
#		print_if_active(["Active path after moving: ", active_path])
		navigation_grid.enter_new_cell(self)
		active_path.pop_front()
		path_line.remove_point(0)




func refill_time_units():
	current_time_units = time_units
func is_enemy_near() -> bool:
	return navigation_grid.get_adjacent_units(self, group).size() > 0
func get_my_cell():
	current_cell = navigation_grid.get_cell(global_position)
func get_adjacent_cells():
	adjacent_cells = navigation_grid.get_adjacent_cells(current_cell)

func update_path_line():
	path_line.clear_points()
	for point in active_path:
		path_line.add_point(map.map_to_local(point))
