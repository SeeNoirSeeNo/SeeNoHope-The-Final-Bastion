extends CharacterBody2D

class_name Unit

### SIGNALS ###
signal turn_finished()
signal movement_finished()
### ENUMS ###
enum State {IDLE, MOVING, ATTACKING, TURN_FINISHED, ROUND_FINISHED}
### @EXPORT ###
### @ONREADY ###
@onready var map = $"../../../Map".get_child(0)
@onready var navigation_grid : NavigationGrid = $"../../../Agents/NavigationGrid"
@onready var path_line : Line2D = $"../../../Agents/NavigationGrid/PathIndicator"
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite = $Sprite2D

### VARIABLES ###
var active_path: Array[Vector2i]
var current_cell : Vector2i
var adjacent_cells : Dictionary
var state = State.IDLE
#var target_position : Vector2
@export var unit_type : String
@export var speed : int
@export var time_units : int
var current_time_units : int
var is_done_for_the_round : bool = false

@export var health_points : int
var current_health_points : int

var attack_range : int = 1
var actions : Dictionary = { "move" : 20, "attack" : 40}
var group : String

var is_active : bool = false

### FUNCTIONS ###
func _ready():
	await get_tree().process_frame #HACK: Wait so everything is init correctly and does not crash...
	initiliaze_variables()

func _process(delta):
	if state == State.MOVING:
		move_along_path(delta)
		play_movement_anim()
	if state == State.IDLE:
		play_idle_anim()
	if state == State.ATTACKING:
		play_attack_anim()
		
func _draw():
	if is_active:
		draw_circle(Vector2.ZERO, 15, Color.RED)

func set_active(active : bool) -> void:
	is_active = active
	queue_redraw()

func play_movement_anim(): #Implemented in Children
	if animation_player.has_animation("Run"):
		animation_player.play("Run")
		
func play_idle_anim(): #Implemented in Children
	if animation_player.has_animation("Idle"):
		animation_player.play("Idle")
		
func play_attack_anim(): #Implemented in Children
	if animation_player.has_animation("Attack"):
		animation_player.play("Attack")
func start_turn():
#?#	print("I am ", self, " and it's my turn! I choose my action now: ")
	choose_action()

func choose_action():
	if current_time_units >= actions["attack"] && is_enemy_near():
		state = State.ATTACKING
		attack()
	elif current_time_units >= actions["move"] && not is_enemy_near():
		state = State.MOVING
		move()
	elif current_time_units >= actions.values().min() && not is_done_for_the_round: #SHOULD COMPARISSION BE TURNED AROUND?!
		state = State.TURN_FINISHED
		end_turn()
	else:
		state = State.ROUND_FINISHED
		end_round()

func attack():
	print("I am ", self, " and I choose to attack!")


func move():
	current_cell = get_my_current_cell()
	print("I am ", self, " at cell ", current_cell, " and I choose to move!")
	var destination = get_destination()
	active_path = get_path_to_destination(current_cell, destination)
	active_path = pay_movement_cost_and_update_path()
	state = State.MOVING
	update_path_line()


#NEEDS MORE TESTING#
func flip_sprite(current_pos, next_pos):
	# Flip the sprite based on the direction of movement
	print(current_pos.x, next_pos.x)
	if current_pos.x > next_pos.x:
		sprite.flip_h = true # Moving to the right
	else:
		sprite.flip_h = false # Moving to the left
		
func move_along_path(delta):
	if active_path.is_empty():
		current_cell = get_my_current_cell()
		navigation_grid.add_unit_to_dict(self)
		adjacent_cells = navigation_grid.get_adjacent_cells(current_cell)
		state = State.IDLE
		set_active(false)
		emit_signal("turn_finished")
		return

	var next_cell = active_path.front() # Next Cell Of The Path
	if active_path.size() > 1:
		navigation_grid.set_cells_solid_state(active_path.back(), true)
		flip_sprite(current_cell, active_path.front()) #Works, but I don't have a good feeling about it
	navigation_grid.set_cells_solid_state(current_cell, false)

	global_position = global_position.move_toward(map.map_to_local(next_cell), speed * delta)
	navigation_grid.erase_unit_from_dict(self)
	
	if global_position == map.map_to_local(next_cell):
		navigation_grid.redraw_grid()
		active_path.pop_front()

#		print_if_active(["Active path after moving: ", active_path])
		path_line.remove_point(0)


func end_turn():
	print("I am ", self, " and I am ending my TURN!")
	pass

func end_round():
	print("I am ", self, " and I am ending my ROUND!")
	pass



func get_my_current_cell(): #Vector2i
	return navigation_grid.get_cell(global_position)
	
func get_destination() -> Vector2i:
	var destination = navigation_grid.get_closest_unit_cell(self, group)
	return destination

func get_path_to_destination(current_cell, destination) -> Array[Vector2i] :
	var path = navigation_grid.astar.get_id_path(current_cell, destination)
	return path



#Only the active unit should print the print commands
func print_if_active(args: Array):
	if is_active:
		print(args)

#Init child variables -> ._ready() might be needed later
func initiliaze_variables():
	add_to_group(group) #Add the Unit to the correct group
	current_cell = get_my_current_cell() #Save where the unit is
	adjacent_cells = navigation_grid.get_adjacent_cells(current_cell) #Makes only sense for meele
	current_health_points = health_points
	current_time_units = time_units



func pay_movement_cost_and_update_path() -> Array[Vector2i]:
#?#	print_if_active(["time_units: ", current_time_units])
	var cells_to_move = min(current_time_units / actions["move"], active_path.size() -1) # -1 to exclude current_cell (???)
#?#	print_if_active(["Cells to move: ", cells_to_move])
	current_time_units -= cells_to_move * actions["move"]
	print_if_active(["Current time units after paying for movement: ", current_time_units])
	var path = active_path.slice(0, int(cells_to_move) +1) # +1 because we count the first cell as well (???)
#?#	print_if_active(["My Active Path after paying for movement: ", path])
	return path


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
