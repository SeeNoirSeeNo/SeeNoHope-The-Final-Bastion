extends Node

class_name Timeline

signal round_finished(current_round)
signal timeline_updated(timeline)

var current_round : int = 1
var timeline : Array = [] #List of all units
var current_unit : Unit = null #The unit who's turn it is


func add_unit(unit : Node) -> void:
#	print("Adding unit to timeline: ", unit.unit_type)
	timeline.append(unit)
	timeline.sort_custom(compare_timeunits)
	emit_signal("timeline_updated", timeline)
#	print("Current timeline: ", timeline)
	
func _on_unit_created(unit):
	add_unit(unit)

func _on_unit_died(unit):
	timeline.erase(unit)
	timeline.sort_custom(compare_timeunits)
	emit_signal("timeline_updated", timeline)
#?#	print("Timeline: I ERASED UNIT FROM TIMELINE: ", unit)

	
func start_turn() -> void:
	await get_tree().create_timer(0.11).timeout
	if timeline.size() > 0:
		if current_unit != null:
			current_unit.set_active(false)
		emit_signal("timeline_updated", timeline)
		current_unit = timeline.front()	
		current_unit = timeline.pop_front()
#?#		print("Starting turn for unit: ", current_unit.unit_type)
		current_unit.set_active(true)
		current_unit.start_turn()

func _on_turn_finished():
	end_turn()
	
func end_turn() -> void:
#?#	print("Ending turn for unit: ", current_unit.unit_type, "\n")
	if all_units_done_for_round():
		if current_unit != null:
			timeline.append(current_unit)
#?#		print("All units done for the round. Starting new round.")
		start_new_round()
	else:

		if current_unit != null:
			timeline.append(current_unit)
			timeline.sort_custom(compare_timeunits)
			#emit_signal("timeline_updated", timeline)
#?#			for unit in timeline:
#?#				var tu = unit.current_timeunits
#?#				print(unit, "My Time units: ", tu)
#?#			print("Current timeline AFTER custom sorting: ", timeline)
			current_unit = null
		start_turn()


func compare_timeunits(unit1 : Unit, unit2 : Unit) -> bool:
	# First, prioritize units that are not done for the round
	if unit1.is_done_for_the_round and not unit2.is_done_for_the_round:
		return false  # unit2 should come before unit1
	elif not unit1.is_done_for_the_round and unit2.is_done_for_the_round:
		return true  # unit1 should come before unit2

	# If both units have the same done status, compare based on current_timeunits
	return unit1.current_timeunits > unit2.current_timeunits


func print_timeunits(timeline : Array) -> void:
	for unit in timeline:
		var tu = unit.current_timeunits
		print(unit, "My Time units: ", tu)

func all_units_done_for_round() -> bool:
	for unit in timeline:
		if not unit.is_done_for_the_round:
			return false
	return true

func start_new_round() -> void:
	current_round += 1
	print("\nStarting new round: ", current_round, "\n")
	print("\nStarting new round\n")
	emit_signal("round_finished", current_round)
	await get_tree().create_timer(1.25).timeout
	for unit in timeline:
		unit.is_done_for_the_round = false
		unit.refill_timeunits()
	start_turn()
