extends Node

### SIGNALS ###
### @EXPORT ###
@export var music : AudioStream
### @ONREADY ###
@onready var map_picker = $Agents/MapPicker
@onready var navigation_grid : NavigationGrid = $Agents/NavigationGrid
@onready var unit_factory : UnitFactory = $Agents/UnitFactory
@onready var timeline : Timeline = $Agents/Timeline
@onready var timeline_bar = $Battle_UI/Control/HBoxContainer/TimeLineBar
@onready var prediction_bar = $Battle_UI/Control/HBoxContainer/PredictionBar
@onready var battle_ui = $Battle_UI
@onready var gamespeed_slider = $Battle_UI/GamespeedSlider



### VARIABLES ###


### FUNCTIONS ###
func _ready():
	connect_signals() #Connect signals for children
	map_picker.load_map() #Load a map (at random)

	unit_factory.create_unit("CaveGoblin", Vector2i(17,3), "Player", "Player", true)
	unit_factory.create_unit("FlyingEye", Vector2i(18,5), "Player", "Player", true)
	unit_factory.create_unit("Necromancer", Vector2i(25,15), "Player", "Player", true)
	unit_factory.create_unit("BananaMan", Vector2i(28,12), "Player", "Player", true)
	unit_factory.create_unit("BananaMan", Vector2i(4,16), "Enemy", "Enemy", true)
	unit_factory.create_unit("CaveGoblin", Vector2i(4,18), "Enemy", "Enemy", true)
	unit_factory.create_unit("Necromancer", Vector2i(5,18), "Enemy", "Enemy", true)
	unit_factory.create_unit("FlyingEye", Vector2i(6,18), "Enemy", "Enemy", true)
	
	Audioplayer.play_music(music)
	
	await get_tree().create_timer(1).timeout #wait a second 
	timeline.start_turn()

func connect_signals():
		map_picker.map_loaded.connect(navigation_grid._on_map_loaded)
		map_picker.map_loaded.connect(unit_factory._on_map_loaded)
		unit_factory.unit_created.connect(navigation_grid._on_unit_created)
		unit_factory.unit_created.connect(timeline._on_unit_created)
		unit_factory.unit_created.connect(self._on_unit_created)
		timeline.round_finished.connect(battle_ui._on_round_finished)
		timeline.round_finished.connect(unit_factory._on_round_finished)
		timeline.timeline_updated.connect(timeline_bar._on_timeline_updated)
		timeline.timeline_updated.connect(prediction_bar._on_timeline_updated)
func _on_unit_created(unit):
	unit.turn_finished.connect(timeline._on_turn_finished)
	unit.unit_died.connect(timeline._on_unit_died)
	unit.unit_died.connect(navigation_grid._on_unit_died)


func _on_gamespeed_button_button_down():
	print("speed2x")
	Engine.time_scale += 2.0


func _on_gamespeed_slider_value_changed(value):
	Engine.time_scale = value
	print(Engine.time_scale)
