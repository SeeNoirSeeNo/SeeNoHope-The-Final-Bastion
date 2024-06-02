extends Node
### SIGNALS ###
signal map_loaded(map_name)
### @EXPORT ###
@export var possible_maps : Array[PackedScene]
### @ONREADY ###
@onready var map = $"../../Map"
### VARIABLES ###
var active_map 

### FUNCTIONS ###
func load_map():
	remove_current_map()
	pick_random_map()

#If there is a map loaded, remove the map
func remove_current_map():
	if map.get_child_count() > 0:
		map.remove_child(get_child(0))

func pick_random_map():
	if !possible_maps.is_empty():
		### Pick a random map ###
		var new_map_scene : PackedScene = possible_maps.pick_random()
		### Get it's name ###
		var map_name = new_map_scene.get_path().get_file().get_basename()
		### Add the instance as a child to Map ###
		var new_map_instance = new_map_scene.instantiate()
		map.add_child(new_map_instance)
		### Emit Signal & Map Name
		emit_signal("map_loaded", map_name)
		### DEBUG ###
		print("MapPicker: Map Name = ", map_name)
