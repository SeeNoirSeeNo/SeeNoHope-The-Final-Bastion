extends Node

### SIGNALS ###
### @EXPORT ###
@export var music : AudioStream
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
	unit_factory.create_unit("CaveGoblin", Vector2i(3,18), "Player", "Player", true)
	unit_factory.create_unit("CaveGoblin", Vector2i(4,18), "Player", "Player", true)
	unit_factory.create_unit("FlyingEye", Vector2i(17,8), "Enemy", "Enemy", true)
	unit_factory.create_unit("BananaMan", Vector2i(15,3), "Enemy", "Enemy", true)
	unit_factory.create_unit("FlyingEye", Vector2i(17,3), "Enemy", "Enemy", true)
	Audioplayer.play_music(music)
	
	await get_tree().create_timer(1).timeout #wait a second 
	timeline.start_turn()

func connect_signals():
		map_picker.map_loaded.connect(navigation_grid._on_map_loaded)
		map_picker.map_loaded.connect(unit_factory._on_map_loaded)
		unit_factory.unit_created.connect(navigation_grid._on_unit_created)
		unit_factory.unit_created.connect(timeline._on_unit_created)
		unit_factory.unit_created.connect(self._on_unit_created)
		
func _on_unit_created(unit):
	unit.turn_finished.connect(timeline._on_turn_finished)
	unit.unit_died.connect(timeline._on_unit_died)
	unit.unit_died.connect(navigation_grid._on_unit_died)
