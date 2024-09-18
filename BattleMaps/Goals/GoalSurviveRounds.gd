extends BaseMissionGoal

class_name GoalSurviveRounds

@export var rounds_to_survive: int

func check_goal() -> bool:
	# Implement logic to check if the required rounds have been survived
	return true

func get_goal_description() -> String:
	return "Survive for %d rounds" % rounds_to_survive
