extends Node

### FOR NOW THIS IS JUST A LIST OF ALL UNIT_TYPES IN THE GAME
### MAYBE I WILL MAKE IT MORE DYNAMIC IN THE FUTURE WITH THE REGISTER_UNIT METHOD

#List of all Unit_Types
var possible_units = ["FlyingEye", "CaveGoblin", "BananaMan", "Necromancer"]


func get_possible_units() -> Array:
	return possible_units



#If unit_type is not registered yet, register it
func register_unit(unit_name: String):
	if unit_name not in possible_units:
		possible_units.append(unit_name)
		print("UnitList: ", unit_name, " registered!")
