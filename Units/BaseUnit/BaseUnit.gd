extends CharacterBody2D

class_name Unit

### SIGNALS ###
signal turn_finished()
signal movement_finished()
### ENUMS ###
enum State {IDLE, MOVING, ATTACKING, HIT, DEAD, TURN_FINISHED, ROUND_FINISHED}
### @EXPORT ###
@export var unit_type : String
@export var speed : int
@export var timeunits : int
@export var damage : int
### @ONREADY ###
@onready var map = $"../../../Map".get_child(0)
@onready var navigation_grid : NavigationGrid = $"../../../Agents/NavigationGrid"
@onready var path_line : Line2D = $"../../../Agents/NavigationGrid/PathIndicator"
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var healthbar : TextureProgressBar = $Healthbar
@onready var TU_bar : TextureProgressBar = $TimeunitsBar



### VARIABLES ###
var active_path: Array[Vector2i]
var current_cell : Vector2i
var adjacent_cells : Dictionary
var state = State.IDLE
var is_dead = false
var current_timeunits : int
var is_done_for_the_round : bool = false

@export var health_points : int
var current_health_points : int

var attack_range : int = 1
var actions : Dictionary = { "move" : 10, "attack" : 40}
var group : String

var is_active : bool = false

### FUNCTIONS ###
func _ready():
	await get_tree().process_frame #HACK: Wait so everything is init correctly and does not crash...
	initiliaze_variables()

func _process(delta):
	if state == State.MOVING:
		move_along_path(delta)
		play_animation("Movement")

	if state == State.IDLE:
		play_animation("Idle")
		
	if state == State.HIT:
		play_animation("TakeHit")
		await animation_player.animation_finished
		state = State.IDLE
#
#	if current_health_points <= 0:
#		state = State.DEAD

	if state == State.DEAD:
		if is_dead == false:
			play_animation("Death")
			await animation_player.animation_finished
			healthbar.hide()
			TU_bar.hide()
			is_dead = true


func _draw():
	if is_active:
		var color = Color(1.0, 1.0, 1.0, 1.0) # Default to light blue
		if is_in_group("Enemy"):
			color = Color(1.0, 0.5, 0.5, 0.25) # Light red for enemies
		elif is_in_group("Player"):
			color = Color(0.0, 0.5, 1.0, 0.25) # Light blue for players
		draw_circle(Vector2.ZERO, 15, color)


#	if is_active:
#		draw_circle(Vector2.ZERO, 15, Color.RED)

func set_active(active : bool) -> void:
	is_active = active
	queue_redraw()



func play_animation(anim : String) -> void :
	if animation_player.has_animation(anim):
		animation_player.play(anim)

func start_turn():
#?#	print("I am ", self, " and it's my turn! I choose my action now: ")
	choose_action()

func choose_action():
	if current_timeunits >= actions["attack"] && is_alive_enemy_near():
		state = State.ATTACKING
		attack()
	elif current_timeunits >= actions["move"] && not is_alive_enemy_near():
		state = State.MOVING
		move()
	elif current_timeunits >= actions.values().min() && not is_done_for_the_round: #SHOULD COMPARISSION BE TURNED AROUND?!
		state = State.TURN_FINISHED
		end_turn()
	else:
		state = State.ROUND_FINISHED
		end_round()

func attack():
	print("I am ", self, " and I choose to attack!")
	var adjacent_enemies : Array = navigation_grid.get_adjacent_units(self, group)
	var alive_enemies = adjacent_enemies.filter(func(enemy): return !enemy.is_dead)
	if alive_enemies.is_empty():
		emit_signal("turn_finished")
	else:
		var target_enemy : Unit = alive_enemies.pick_random()
		flip_sprite_combat(current_cell, target_enemy.current_cell)
		play_animation("Attack")
		target_enemy.current_health_points -= damage
		if target_enemy.current_health_points <= 0:
			target_enemy.state = State.DEAD
		else:
			target_enemy.state = State.HIT
		target_enemy.update_healthbar(target_enemy)
		await animation_player.animation_finished
		print(target_enemy.current_health_points)
		end_turn()



func move():
	current_cell = get_my_current_cell()
	print("I am ", self, " at cell ", current_cell, " and I choose to move!")
	var destination = get_destination()
	active_path = get_path_to_destination(current_cell, destination)
	active_path = pay_movement_cost_and_update_path()
	update_path_line()


func flip_sprite_combat(self_position, enemy_position):
	# Flip the sprite based on the direction of movement
	if self_position.x > enemy_position.x:
		sprite.flip_h = true # Moving to the right
	else:
		sprite.flip_h = false # Moving to the left


#NEEDS MORE TESTING#
func flip_sprite(current_pos, next_pos):
	# Flip the sprite based on the direction of movement
	if current_pos.x > next_pos.x:
		sprite.flip_h = true # Moving to the right
	else:
		sprite.flip_h = false # Moving to the left
		
func move_along_path(delta):
	if active_path.is_empty():
		current_cell = get_my_current_cell()
		navigation_grid.add_unit_to_dict(self)
		adjacent_cells = navigation_grid.get_adjacent_cells(current_cell)
		end_turn()
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
	state = State.IDLE
	set_active(false)
	emit_signal("turn_finished")

func end_round():
	print("I am ", self, " and I am ending my ROUND!")
	state = State.ROUND_FINISHED
	set_active(false)
	emit_signal("turn_finished")




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
	current_timeunits = timeunits
	update_healthbar(self)
	update_TU_bar(self)


func pay_movement_cost_and_update_path() -> Array[Vector2i]:
#?#	print_if_active(["timeunits: ", current_timeunits])
	var cells_to_move = min(current_timeunits / actions["move"], active_path.size() -1) # -1 to exclude current_cell (???)
#?#	print_if_active(["Cells to move: ", cells_to_move])
	current_timeunits -= cells_to_move * actions["move"]
	print_if_active(["Current time units after paying for movement: ", current_timeunits])
	var path = active_path.slice(0, int(cells_to_move) +1) # +1 because we count the first cell as well (???)
#?#	print_if_active(["My Active Path after paying for movement: ", path])
	update_TU_bar(self)
	return path


func refill_timeunits():
	current_timeunits = timeunits
func is_enemy_near() -> bool:
	return navigation_grid.get_adjacent_units(self, group).size() > 0
func is_alive_enemy_near() -> bool:
	var adjacent_enemies : Array = navigation_grid.get_adjacent_units(self, group)
	var alive_enemies = adjacent_enemies.filter(func(enemy): return !enemy.is_dead)
	return alive_enemies.size() > 0
	
func get_my_cell():
	current_cell = navigation_grid.get_cell(global_position)
func get_adjacent_cells():
	adjacent_cells = navigation_grid.get_adjacent_cells(current_cell)

func update_path_line():
	path_line.clear_points()
	for point in active_path:
		path_line.add_point(map.map_to_local(point))

func update_healthbar(caller):
	healthbar.update(caller)
func update_TU_bar(caller):
	TU_bar.update(caller)
