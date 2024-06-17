extends Node2D
class_name NavigationGrid

### SIGNALS ###
### @EXPORTS ###
### @ONREADY ###
@onready var map = $"../../Map"
### VARIABLES ###
var astar: AStarGrid2D 
var tile_map: TileMap
var units: Dictionary = { }
var free_cells: Array[Vector2i]
var occupied_cells: Array[Vector2i]
var free_cells_local: Array[Vector2]
var occupied_cells_local: Array[Vector2]
var previous_mouse_grid_position : Vector2i
### DEBUG ###
var draw_circles = false


func _process(delta):
	if draw_circles:
		var current_mouse_grid_position = get_cell(get_global_mouse_position())
		if current_mouse_grid_position != previous_mouse_grid_position:
			previous_mouse_grid_position = current_mouse_grid_position
			print(current_mouse_grid_position)


func erase_unit_from_dict(unit):
	if units.has(unit.current_cell):
		units.erase(unit.current_cell)
		print("NavigationGrid: UnitDict AFTER unit left old cell: ", units)


func add_unit_to_dict(unit):
	units[unit.current_cell] = unit 
	print("NavigationGrid: UnitDict after unit walking_to_new_cell: ", units)


#Sets a cells SOLID attribute to TRUE or FALSE
func set_cells_solid_state(cell, state):
	if cell != null:
		astar.set_point_solid(cell, state)
	if state == true:
		occupied_cells.append(cell)
		if free_cells.has(cell):
			free_cells.erase(cell)
	else:
		free_cells.append(cell)
		if occupied_cells.has(cell):
			occupied_cells.erase(cell)

func redraw_grid():
	queue_redraw()

#PRESS-E for DEBUG Info
func _input(event):
	if event.is_action_pressed("debug"):
		draw_circles = !draw_circles
		queue_redraw()



#Draw Debug Info
func _draw():
	if draw_circles:
		for cell in free_cells:
			draw_circle(tile_map.map_to_local(cell), 3, Color.GREEN)
		for cell in occupied_cells:
			draw_circle(tile_map.map_to_local(cell), 3, Color.RED)



### FUNCTIONS ###
#STARTS WHEN MAP WAS LOADED
func _on_map_loaded(_map_name): #Initalize A*GRID2D
	get_tile_map() #Get the current tile map
	init_astar() #Apply the AStarGrid2D
	###DEBUG###
#	print("NavigationGrid: Init of AStarfinished!")

#When a unit is created, we put it in the units dict and block the cell
func _on_unit_created(unit: Unit):
	units[unit.current_cell] = unit #Add Unit To Units Dictionary
	set_cells_solid_state(unit.current_cell, true) #Make Cell Solid
	print("NavigationGrid: UnitDict after unit was created: ", units)


#Converts Local (Global?) Position To Grid Coords
func get_cell(local_position: Vector2) -> Vector2i:
	return tile_map.local_to_map(local_position)

#Returns a Dict of all adjacent cells in relation to the cell passed as an argument
func get_adjacent_cells(cell : Vector2i):
	var directions = {
		"top_left" : Vector2i(-1, -1), "top" : Vector2i(0, -1), "top_right" : Vector2i(1, -1),
		"left" : Vector2i(-1, 0),                  "right" : Vector2i(1, 0),
		"bottom_left" : Vector2i(-1, 1), "bottom" : Vector2i(0, 1), "bottom_right" : Vector2i(1, 1)
	}
	var adjacent_cells = {}
	for direction in directions:
		adjacent_cells[direction] = cell + directions[direction]
	
	return adjacent_cells

#Gets adjacent units if they belong to group
func get_adjacent_units(caller: Unit, group: String):
	var adjacent_units = []
	for cell in caller.adjacent_cells.values():
		if units.has(cell) && units[cell].group != group:
			adjacent_units.append(units[cell])
	return adjacent_units


func get_closest_unit_cell(caller: Unit, group: String) -> Vector2i:
	var closest_cell = null
	var closest_distance = INF
	var start = caller.current_cell
	
	print("Start cell: ", start)
	print("All Units: ", units)
	for cell in units.keys():
		print("\nChecking cell: ", cell)
		if cell == caller.current_cell:  # Skip the caller itself
			print("Skipping caller's cell")
			continue
		if units[cell].group != group:
			print("Cell belongs to enemy group")
			var enemy_cells = get_adjacent_cells(cell)
			print("Enemy Cells: ", enemy_cells)
			for enemy_cell in enemy_cells.values():
				if astar.is_point_solid(enemy_cell):  # Skip solid cells
					print("Skipping solid cell: ", enemy_cell)
					continue
				print("Checking enemy cell: ", enemy_cell)
				var path = astar.get_id_path(start, enemy_cell)
				print("Path from start to enemy cell: ", path)
				var distance = path.size()
				print("Distance from start to enemy cell: ", distance)
				if distance < closest_distance:
					print("Found closer cell")
					closest_distance = distance
					closest_cell = enemy_cell
		else:
			print("Cell belongs to same group")
	
	if closest_cell == null:
		print("No enemy cells found")
		return Vector2i.ZERO
	else:
		print("Closest enemy cell: ", closest_cell)
		return closest_cell
		







func get_tile_map(): #Used _on_map_loaded
	tile_map = map.get_child(0)





func init_astar(): #Used _on_map_loaded
	astar = AStarGrid2D.new() #create grid
	astar.region = tile_map.get_used_rect() #get region size
	astar.cell_size = Vector2(32, 32) #set cell size 
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS #diagonal yes/no
	astar.update() #update grid with new settings

	#Scan All Tiles & Set Solid if Walkable = false
	for x in range(int(tile_map.get_used_rect().size.x)):
		for y in range(int(tile_map.get_used_rect().size.y)):
			var tile_position = Vector2i(
				x + int(tile_map.get_used_rect().position.x),
				y + int(tile_map.get_used_rect().position.y)
			)
			
			var is_solid = false
			for layer in range(tile_map.get_layers_count()):  # Iterate over the layers
				var tile_data = tile_map.get_cell_tile_data(layer, tile_position)
				if tile_data != null and tile_data.get_custom_data("walkable") == false:
					is_solid = true
					occupied_cells.append(tile_position)
					occupied_cells_local.append(tile_map.map_to_local(tile_position))
					break  # No need to check other layers if one is not walkable
				else:
					free_cells.append(tile_position) #Just use a method to convert those?
					free_cells_local.append(tile_map.map_to_local(tile_position)) #Just use a method to convert those?
				
			astar.set_point_solid(tile_position, is_solid)





func get_free_random_cell(): #Returns a random free cell in grid coords
	var free_cell = free_cells.pick_random()
	return free_cell

func get_free_random_cell_local(): #Returns a random free cell in pixel coords
	var free_cell = free_cells_local.pick_random()
	return free_cell
