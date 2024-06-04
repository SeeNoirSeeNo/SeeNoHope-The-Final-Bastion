extends Node2D


### SIGNALS ###
### @EXPORTS ###
### @ONREADY ###
@onready var map = $"../../Map"
### VARIABLES ###
var astar: AStarGrid2D 
var tile_map: TileMap
var free_cells: Array[Vector2i]
var occupied_cells: Array[Vector2i]
var free_cells_local: Array[Vector2]
var occupied_cells_local: Array[Vector2]
var previous_mouse_grid_position : Vector2i
### DEBUG ###
var draw_circles = false

func _input(event):
	if event.is_action_pressed("debug"):
		draw_circles = !draw_circles
		queue_redraw()
		print("NavigationGrid: Draw Circles = ", draw_circles)
		
func _draw():
	if draw_circles:
		for cell in free_cells_local:
			draw_circle(cell, 3, Color.GREEN)
		for cell in occupied_cells_local:
			draw_circle(cell, 3, Color.RED)

func _process(delta):
	if draw_circles:
		var current_mouse_grid_position = get_mouse_grid_position()
		if current_mouse_grid_position != previous_mouse_grid_position:
			previous_mouse_grid_position = current_mouse_grid_position
			print(current_mouse_grid_position)
		
### FUNCTIONS ###
#STARTS WHEN MAP WAS LOADED
func _on_map_loaded(_map_name): #Initalize A*GRID2D
	get_tile_map() #Get the current tile map
	init_astar() #Apply the AStarGrid2D
	###DEBUG###
	print("NavigationGrid: Init of AStarfinished!")

#Converts Global Mouse Position To Grid Coords
func get_mouse_grid_position():
	return tile_map.local_to_map(get_global_mouse_position())


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

func get_free_cell(): #Returns a free cell in grid coords
	var free_cell = free_cells.pick_random()
	return free_cell

func get_free_cell_local(): #Returns a free cell in pixel coords
	var free_cell = free_cells_local.pick_random()
	return free_cell
