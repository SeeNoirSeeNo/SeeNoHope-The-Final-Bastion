extends Node

class_name Timeline

var timeline : Array = [] #List of all units
#var current_unit : Node = null #The unit who's turn it is
var current_unit : Unit = null #The unit who's turn it is

func add_unit(unit : Node) -> void:
#	print("Adding unit to timeline: ", unit.unit_type)
	timeline.append(unit)
	timeline.sort_custom(compare_timeunits)
#	print("Current timeline: ", timeline)
	
func _on_unit_created(unit):
#	print("Unit created: ", unit.unit_type)	
	add_unit(unit)


func start_turn() -> void:
	await get_tree().create_timer(1).timeout
	if timeline.size() > 0:
		if current_unit != null:
			current_unit.set_active(false)
		current_unit = timeline.front()	
		current_unit = timeline.pop_front()
		print("Starting turn for unit: ", current_unit.unit_type)
		current_unit.set_active(true)
		current_unit.start_turn()

func _on_turn_finished():
	end_turn()
	
func end_turn() -> void:
	print("Ending turn for unit: ", current_unit.unit_type, "\n")
	if all_units_done_for_round():
		print("All units done for the round. Starting new round.")
		start_new_round()
	else:

		if current_unit != null:
			timeline.append(current_unit)
			timeline.sort_custom(compare_timeunits)
			for unit in timeline:
				var tu = unit.current_timeunits
#?#				print(unit, "My Time units: ", tu)
#?#			print("Current timeline AFTER custom sorting: ", timeline)
			current_unit = null
		start_turn()



func compare_timeunits(unit1 : Unit, unit2 : Unit) -> bool:
	if unit1.current_timeunits > unit2.current_timeunits:
		return true
	else:
		return false


func print_timeunits(timeline : Array) -> void:
	for unit in timeline:
		var tu = unit.current_timeunits
#?#		print(unit, "My Time units: ", tu)

func all_units_done_for_round() -> bool:
	for unit in timeline:
		if not unit.is_done_for_the_round:
			return false
	return true

func start_new_round() -> void:
	print("Starting new round.")
	for unit in timeline:
		unit.is_done_for_the_round = false
		unit.refill_timeunits()
