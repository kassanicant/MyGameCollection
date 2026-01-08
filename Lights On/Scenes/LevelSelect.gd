extends Control

func _ready():
	# 1. Connect Level Buttons (1-5)
	for i in range(1, 6):
		var btn_name = "BtnLevel" + str(i)
		var btn = find_child(btn_name, true, false)
		
		if btn:
			if not btn.pressed.is_connected(load_level):
				btn.pressed.connect(load_level.bind(i))
	
	# 2. Connect Back Button (The Foolproof Way)
	# First, try to find a button named "BackButton"
	var back_btn = find_child("BackButton", true, false)
	
	# If not found, look for ANY TextureButton that isn't a Level Button
	if not back_btn:
		var all_btns = find_children("*", "TextureButton", true, false)
		for b in all_btns:
			if "BtnLevel" not in b.name:
				back_btn = b
				break
	
	# 3. Connect the signal
	if back_btn:
		print("Back Button Connected: ", back_btn.name)
		if not back_btn.pressed.is_connected(_on_back_pressed):
			back_btn.pressed.connect(_on_back_pressed)
	else:
		print("CRITICAL ERROR: No Back Button found on screen!")

func load_level(level_num):
	GlobalAudio.play_click()
	Global.current_level = level_num
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_back_pressed():
	GlobalAudio.play_click()
	get_tree().change_scene_to_file("res://Scenes/Main_Menu.tscn")
