extends Node

### SIGNALS ###
### @EXPORT ###
### @ONREADY ###
@onready var map_picker = $Agents/MapPicker
@onready var navigation_grid : Node2D = $Agents/NavigationGrid
@onready var unit_factory : UnitFactory = $Agents/UnitFactory
### VARIABLES ###


### FUNCTIONS ###
func _ready():
	connect_signals() #Connect signals for children
	map_picker.load_map() #Load a map (at random)
	for i in range(5): 
		var random_cell = navigation_grid.get_free_cell_local()
		unit_factory.create_unit("CaveGoblin", random_cell, "Enemy", "Enemy")
		random_cell = navigation_grid.get_free_cell_local()
		unit_factory.create_unit("FlyingEye", random_cell, "Enemy", "Enemy")
		print(navigation_grid.tile_map.local_to_map(random_cell))

	
func connect_signals():
		map_picker.map_loaded.connect(navigation_grid._on_map_loaded)
		map_picker.map_loaded.connect(unit_factory._on_map_loaded)
