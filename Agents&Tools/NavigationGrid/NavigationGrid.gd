extends Node2D


### SIGNALS ###
### @EXPORTS ###
### @ONREADY ###
@onready var map = $"../../Map"
### VARIABLES ###
var astar: AStarGrid2D 
var tile_map: TileMap
### FUNCTIONS ###

#STARTS WHEN MAP WAS LOADED
func _on_map_loaded(_map_name): #Initalize A*GRID2D
	get_tile_map() #Get the current tile map
	init_astar() #Apply the AStarGrid2D
	###DEBUG###
	print("NavigationGrid: Init of AStarfinished!")

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
					break  # No need to check other layers if one is not walkable

			astar.set_point_solid(tile_position, is_solid)
