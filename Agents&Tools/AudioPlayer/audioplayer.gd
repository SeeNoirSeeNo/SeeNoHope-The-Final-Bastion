extends Node2D

@onready var sfx = $SFX
@onready var music = $Music


func play_sound(sound: AudioStream) -> void:
	if sound != null:
		sfx.stream = sound
		sfx.play()

func play_music(sound: AudioStream) -> void:
	if sound != null:
		music.stream = sound
		music.play()
