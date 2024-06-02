extends Node

### SIGNALS ###
### @EXPORT ###
### @ONREADY ###
@onready var map_picker = $Agents/MapPicker
@onready var navigation_grid = $Agents/NavigationGrid
@onready var unit_factory = $Agents/UnitFactory
### VARIABLES ###


### FUNCTIONS ###
func _ready():
	connect_signals() #Connect signals for children
	map_picker.load_map() #Load a map (at random)

func connect_signals():
		map_picker.map_loaded.connect(navigation_grid._on_map_loaded)
		map_picker.map_loaded.connect(unit_factory._on_map_loaded)
