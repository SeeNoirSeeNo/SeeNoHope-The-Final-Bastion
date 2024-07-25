extends CharacterBody2D

class_name Unit
### SIGNALS ###
signal turn_finished()
signal movement_finished()
signal unit_died(unit)
### ENUMS ###
enum State {IDLE, MOVING, ATTACKING, HIT, DEAD, TURN_FINISHED, ROUND_FINISHED}
### @EXPORT ###
@export var unit_type : String
@export var speed : int
@export var timeunits : int
@export var move_sound : AudioStream
@export var attack_sound : AudioStream
@export var death_sound : AudioStream
@export var hit_sound : AudioStream
@export var health_points : int
@export var base_min_damage : int
@export var base_max_damage : int
@export var life_leech : int
@export var move_cost : int
@export var attack_cost : int
@export var wait_cost : int
@export var attack_range : int = 1
@export var evasion_chance : int = 0
### @ONREADY ###
@onready var map = $"../../../Map".get_child(0)
@onready var navigation_grid : NavigationGrid = $"../../../Agents/NavigationGrid"
@onready var path_line : Line2D = $"../../../Agents/NavigationGrid/PathIndicator"
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var healthbar : TextureProgressBar = $Healthbar
@onready var TU_bar : TextureProgressBar = $TimeunitsBar



### VARIABLES ###

var actions : Dictionary
var active_path: Array[Vector2i]
var current_cell : Vector2i
var adjacent_cells : Dictionary
var state = State.IDLE
var is_dead = false
var current_timeunits : int
var is_done_for_the_round : bool = false
var min_damage
var max_damage
var label_velocity: Vector2 = Vector2(8,-20)
var label_duration: float = 0.8
var current_health_points : int
var group : String
var is_active : bool = false

### FUNCTIONS ###
func _ready():
	await get_tree().process_frame #HACK: Wait so everything is init correctly and does not crash...
	initiliaze_variables()

func _process(delta):
	if state == State.MOVING:
		play_animation("Run")
		move_along_path(delta)
	if state == State.IDLE:
		play_animation("Idle")
	if state == State.HIT:
		play_animation("TakeHit")
		await animation_player.animation_finished
		state = State.IDLE
	if state == State.DEAD:
		if is_dead == false:
			is_dead = true
			play_animation("Death")
			Audioplayer.play_sound(death_sound)
			emit_signal("unit_died", self)
			await animation_player.animation_finished
			healthbar.hide()
			TU_bar.hide()
			queue_redraw()



func attack():
	print("I am ", self, " at cell ", current_cell, " and I choose to attack!")
	var adjacent_enemies : Array = navigation_grid.get_adjacent_units(self, group)
	var alive_enemies = adjacent_enemies.filter(func(enemy): return !enemy.is_dead)
	if alive_enemies.is_empty():
		emit_signal("turn_finished")
	else:
		var target_enemy : Unit = alive_enemies.pick_random()
		flip_sprite_combat(current_cell, target_enemy.current_cell)
		play_animation("Attack")
		Audioplayer.play_sound(attack_sound)
		pay_attack_cost()
		var damage = roll_damage()
		print("damage: ", damage)
		#if target_enemy.evasion_chance > 0:
			#target_enemy.roll_evade()
		deal_damage(target_enemy, damage)
		if life_leech > 0:
			var life_leech_amount = calc_life_leech(damage)
			print("life_leech_amount: ", life_leech_amount)
			self_heal(life_leech_amount, life_leech_amount)
		await animation_player.animation_finished
		end_turn()
		
#func roll_evade():
	#var random_number = randi() % 100
	#print("evade random_number: ", random_number)
	#return evasion_chance < random_number
	
func calc_life_leech(damage):
	var life_leech_amount = (damage * life_leech) / 100
	return life_leech_amount
	


func roll_damage() -> int:
	return randi_range(min_damage, max_damage)
	
func pay_wait_cost():
	current_timeunits -= actions["wait"]
	update_TU_bar(self)


func pay_attack_cost():
	current_timeunits -= actions["attack"]
	update_TU_bar(self)


func _draw():
	var color = Color(1.0, 1.0, 1.0, 0.0) # Init invisible circle
	if is_active:
		if is_in_group("Enemy"):
			color = Color(1.0, 0.5, 0.5, 0.55) # Light red for enemies
		elif is_in_group("Player"):
			color = Color(0.0, 0.5, 1.0, 0.55) # Light blue for players
	else:
		if not is_dead:
			if is_in_group("Enemy"):
				color = Color(1.0, 0.5, 0.5, 0.15) # Light red for enemies
			elif is_in_group("Player"):
				color = Color(0.0, 0.5, 1.0, 0.15) # Light blue for players
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
	### ATTACK ###
	if current_timeunits >= actions["attack"] && is_alive_enemy_near():
		state = State.ATTACKING
		attack()
	### MOVE ###
	elif current_timeunits >= actions["move"] && not is_alive_enemy_near():
		state = State.MOVING
		move()
	### WAIT ###
	elif current_timeunits >= actions.values().min() && not is_done_for_the_round: #SHOULD COMPARISSION BE TURNED AROUND?!
		state = State.TURN_FINISHED
		pay_wait_cost()
		end_turn()
	else:
		### END ROUND ###
		current_timeunits = 0
		state = State.ROUND_FINISHED
		is_done_for_the_round = true
		end_round()


func end_of_turn_action():
	pass


	
func deal_damage(target, dmg):
	if target.has_method("take_damage"):
		target.take_damage(dmg)

func take_damage(damage):
	healthbar.create_floating_label(damage, ColorAgent.damage_color, label_velocity, label_duration) #last 2 param make me unhappy
	current_health_points -= damage
	if current_health_points <= 0:
		current_health_points = 0
		state = State.DEAD
	else:
		Audioplayer.play_sound(hit_sound)
		print("\nI am Unit: ", str(self), " And I play my hit sound: ", str(hit_sound), "\n")
		update_healthbar(self)
		state = State.HIT

func move():
	current_cell = get_my_current_cell()
	print("I am ", self, " at cell ", current_cell, " and I choose to move!")
	var destination = get_destination()
	active_path = get_path_to_destination(current_cell, destination)
	active_path = pay_movement_cost_and_update_path()
	Audioplayer.play_looped_sound(move_sound)
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
#?#	print("I am ", self, " at: ", current_cell, "and I am ending my TURN!")
	state = State.IDLE
	set_active(false)
	Audioplayer.stop_sound()
	emit_signal("turn_finished")

func end_round():
#?#	print("I am ", self, " and I am ending my ROUND!")
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
	queue_redraw()
	#Set Damage
	min_damage = base_min_damage
	max_damage = base_max_damage
	#Populate Actions Dict and make sure wait has the correct cost
	actions = {
		"move": move_cost,
		"attack": attack_cost,
	}
	var lowest_cost = INF #Find lowest cost among actions
	for cost in actions.values():
		if cost < lowest_cost:
			lowest_cost = cost
	wait_cost = lowest_cost - 1 #Substract 1 from it
	actions["wait"] = wait_cost #New waiting cost
	print(wait_cost)

func pay_movement_cost_and_update_path() -> Array[Vector2i]:
	if active_path.size() <= 1:
		print("UNIT: NO PATH FOUND!!!")
		current_timeunits -= actions["wait"]
		update_TU_bar(self)
		return []
#?#	print_if_active(["timeunits: ", current_timeunits])
	var cells_to_move = min(current_timeunits / actions["move"], active_path.size() -1) # -1 to exclude current_cell (???)
#?#	print_if_active(["Cells to move: ", cells_to_move])
	current_timeunits -= cells_to_move * actions["move"]
#?#	print_if_active(["Current time units after paying for movement: ", current_timeunits])
	var path = active_path.slice(0, int(cells_to_move) +1) # +1 because we count the first cell as well (???)
#?#	print_if_active(["My Active Path after paying for movement: ", path])
	update_TU_bar(self)
	return path


func refill_timeunits():
	current_timeunits = timeunits
	update_TU_bar(self)



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
	if 	self.group == "Player":
		path_line.self_modulate = ColorAgent.player_color
	else:
		path_line.self_modulate = ColorAgent.enemy_color
	for point in active_path:
		path_line.add_point(map.map_to_local(point))


func update_healthbar(caller):
	healthbar.update(caller)
func update_TU_bar(caller):
	TU_bar.update(caller)



### ABILITIES ###
func self_heal(min, max):
	var heal_amount = randi_range(min, max)
	print("Self Heal: ", heal_amount)
	current_health_points += heal_amount
	if current_health_points > health_points: #prevent over-healing
		current_health_points = health_points
	healthbar.create_floating_label(heal_amount, ColorAgent.heal_color, label_velocity, label_duration) #last 2 param make me unhappy
	update_healthbar(self)
