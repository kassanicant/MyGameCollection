extends Control

# Nodes
@onready var how_to_play_popup = $HowToPlayPopup

func _ready():
	# 1. Connect Start Button
	var start_btn = find_child("StartButton", true, false)
	if start_btn:
		if not start_btn.pressed.is_connected(_on_start_pressed):
			start_btn.pressed.connect(_on_start_pressed)
			
	# 2. Connect How To Play Button
	var htp_btn = find_child("HowToPlayButton", true, false)
	if htp_btn:
		if not htp_btn.pressed.is_connected(_on_htp_pressed):
			htp_btn.pressed.connect(_on_htp_pressed)
		if how_to_play_popup:
			how_to_play_popup.visible = false
			
	# 3. Connect Close Button (Inside the popup)
	if how_to_play_popup:
		var close_btn = how_to_play_popup.find_child("CloseButton", true, false)
		# Fallback: Look for any TextureButton if specific name is wrong
		if not close_btn: 
			close_btn = how_to_play_popup.find_child("TextureButton", true, false)
			
		if close_btn:
			if not close_btn.pressed.is_connected(_on_close_htp_pressed):
				close_btn.pressed.connect(_on_close_htp_pressed)
				
		

func _on_start_pressed():
	if GlobalAudio: GlobalAudio.play_click()
	# Go to Level Select
	get_tree().change_scene_to_file("res://Scenes/LevelSelect.tscn")

func _on_htp_pressed():
	if GlobalAudio: GlobalAudio.play_click()
	# Show Instructions
	if how_to_play_popup:
		how_to_play_popup.visible = true



func _on_close_htp_pressed():
	if GlobalAudio: GlobalAudio.play_click()
	# Hide Instructions
	if how_to_play_popup:
		how_to_play_popup.visible = false
