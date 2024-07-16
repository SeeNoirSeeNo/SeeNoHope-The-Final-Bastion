

extends CanvasLayer
@onready var next_round = $Control/NextRound
@export var next_round_sound : AudioStream

func _ready():
	update_next_round_label(1)
	
func update_next_round_label(round_number):
	next_round.bbcode_text = "[b]STARTING ROUND: [color=red]" + str(round_number) + "[/color][/b]"
	Audioplayer.play_sound(next_round_sound)
	fade_in_out_label()

func _on_round_finished(round_number):
	update_next_round_label(round_number)


func fade_in_out_label():
	var alpha = 0.0
	while alpha < 1.0:
		alpha += get_process_delta_time() / 0.5  # 0.5 seconds for fade-in
		next_round.modulate.a = alpha
		await get_tree().process_frame
		
	await get_tree().create_timer(0.25).timeout
		
	alpha = 1.0
	while alpha > 0.0:
		alpha -= get_process_delta_time() / 0.5  # 0.5 seconds for fade-in
		next_round.modulate.a = alpha
		await get_tree().process_frame
