extends Node

### SIGNALS ###
### @EXPORT ###
### @ONREADY ###
@onready var map_picker = $Agents/MapPicker
@onready var navigation_grid : NavigationGrid = $Agents/NavigationGrid
@onready var unit_factory : UnitFactory = $Agents/UnitFactory
@onready var timeline : Timeline = $Agents/Timeline
### VARIABLES ###


### FUNCTIONS ###
func _ready():
	connect_signals() #Connect signals for children
	map_picker.load_map() #Load a map (at random)

	unit_factory.create_unit("CaveGoblin", Vector2i(2,18), "Player", "Player", true)
	unit_factory.create_unit("CaveGoblin", Vector2i(28,3), "Player", "Player", true)
	unit_factory.create_unit("FlyingEye", Vector2i(26,18), "Enemy", "Enemy", true)
	unit_factory.create_unit("FlyingEye", Vector2i(15,3), "Enemy", "Enemy", true)
	unit_factory.create_unit("FlyingEye", Vector2i(17,3), "Enemy", "Enemy", true)

#SPAWN RANDOM UNITS
#	for i in range(1): 
#		var random_cell = navigation_grid.get_free_random_cell_local()
#		unit_factory.create_unit("CaveGoblin", random_cell, "Enemy", "Enemy")
#		random_cell = navigation_grid.get_free_random_cell_local()
#		unit_factory.create_unit("FlyingEye", random_cell, "Enemy", "Enemy")


func _on_unit_created(unit):
	unit.turn_finished.connect(timeline._on_turn_finished)



	for i in range(5): 
		var random_cell = navigation_grid.get_free_cell_local()
		unit_factory.create_unit("CaveGoblin", random_cell, "Enemy", "Enemy")
		random_cell = navigation_grid.get_free_cell_local()
		unit_factory.create_unit("FlyingEye", random_cell, "Enemy", "Enemy")
		print(navigation_grid.tile_map.local_to_map(random_cell))

	

func connect_signals():
		map_picker.map_loaded.connect(navigation_grid._on_map_loaded)
		map_picker.map_loaded.connect(unit_factory._on_map_loaded)
		unit_factory.unit_created.connect(navigation_grid._on_unit_created)
		unit_factory.unit_created.connect(timeline._on_unit_created)
		unit_factory.unit_created.connect(self._on_unit_created)
