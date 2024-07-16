extends Node2D


### SIGNALS ###
signal sound_finished(audio_player)
### ENUMS ###
### @EXPORT ###
### @ONREADY ###
@onready var looped = $looped
@onready var music = $Music
### VARIABLES ###
var audio_player_pool : Array = []

func _ready():
	for i in range(10): #CREATE 10 ASP's
		var audio_player = AudioStreamPlayer.new()
		add_child(audio_player)
		audio_player_pool.append(audio_player)

func play_sound(sound: AudioStream) -> void:
#	print("AUDIOPLAYERS: ", audio_player_pool)
	if not audio_player_pool.is_empty():
		if sound != null:
			var player = audio_player_pool.pop_front() #Pick the first free ASP
			player.stream = sound
			player.play()
			player.finished.connect(_on_sound_finished.bind(player))


func _on_sound_finished(player):
	player.finished.disconnect(_on_sound_finished.bind(player))
	player.stop()
	audio_player_pool.append(player)

func play_looped_sound(sound: AudioStream) -> void:
	if sound != null:
		looped.stream = sound
		looped.play()
func stop_sound() -> void:
	looped.stop()


func play_music(sound: AudioStream) -> void:
	if sound != null:
		music.stream = sound
		music.play()
func stop_music() -> void:
	music.stop()
