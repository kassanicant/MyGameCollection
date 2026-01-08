# res://GlobalAudio.gd
extends Node

var click_player: AudioStreamPlayer

func _ready():
	# Create the player dynamically
	click_player = AudioStreamPlayer.new()
	add_child(click_player)
	
	# LOAD YOUR SOUND HERE
	# Make sure your file is named "Click.wav" in Assets, or change this line!
	var sound = load("res://Assets/Click.wav") 
	if sound:
		click_player.stream = sound
	else:
		print("ERROR: Click.wav not found in Assets folder!")

func play_click():
	# Randomize pitch slightly for variety (optional)
	click_player.pitch_scale = randf_range(0.95, 1.05)
	click_player.play()
