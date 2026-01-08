extends Node2D

# --- CONFIGURATION ---
var grid_cols = 3
var grid_rows = 3
var base_spacing = 150 
var grid = [] 

# --- GAME STATE ---
var time_left = 0.0
var game_active = false
var is_paused = false 

# --- NODES ---
@onready var grid_holder = $GridHolder
@onready var background = $Background
@onready var ceiling_light = $CeilingLight
@onready var switch_scene = preload("res://Scenes/Switch.tscn")

# --- ASSETS ---
var bg_on = preload("res://Assets/BGOn.png")
var bg_off = preload("res://Assets/BGOff.png")
var light_on = preload("res://Assets/Lights On.png")
var light_off = preload("res://Assets/Lights Off.png")
var icon_pause = preload("res://Assets/PauseButton.png") 
var icon_play = preload("res://Assets/PlayButton.png")

# --- WIN SOUND ---
var win_sound = preload("res://Assets/Win.wav")

# --- UI NODES ---
var win_popup : Control = null 
var game_over_popup : Control = null
var timer_label : Label = null
var menu_button : BaseButton = null
var submenu_popup : Control = null
var restart_button : BaseButton = null
var pause_button : TextureButton = null 
var back_button : BaseButton = null 

# Win Popup Parts
var win_message_img : TextureRect = null
var win_next_btn : BaseButton = null
var win_replay_btn : BaseButton = null

func _ready():
	# 1. FIND NODES SAFELY
	win_popup = find_child("WinPopup", true, false)
	if not win_popup: win_popup = find_child("Control", true, false)
	
	game_over_popup = find_child("GameOverPopup", true, false)
	timer_label = find_child("TimerLabel", true, false)
	menu_button = find_child("MenuButton", true, false)
	submenu_popup = find_child("SubmenuPopup", true, false)
	restart_button = find_child("RestartButton", true, false)
	pause_button = find_child("PauseButton", true, false)
	back_button = find_child("BackButton", true, false) 
	
	# Find Win Popup Parts
	if win_popup:
		win_message_img = win_popup.find_child("MessageImage", true, false)
		win_next_btn = win_popup.find_child("NextButton", true, false)
		win_replay_btn = win_popup.find_child("ReplayButton", true, false)
		
		var hbox = win_popup.find_child("HBoxContainer", true, false)
		if hbox:
			hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	# 2. CENTER & SETUP
	if timer_label: timer_label.text = "00:00"
	
	center_ui_elements()
	connect_buttons()
	start_level()

func connect_buttons():
	if restart_button:
		if not restart_button.pressed.is_connected(restart_level):
			restart_button.pressed.connect(restart_level)
	
	if menu_button:
		if not menu_button.pressed.is_connected(toggle_menu):
			menu_button.pressed.connect(toggle_menu)
			
	if pause_button:
		if not pause_button.pressed.is_connected(_on_pause_pressed):
			pause_button.pressed.connect(_on_pause_pressed)
			
	if back_button:
		if not back_button.pressed.is_connected(_on_back_pressed):
			back_button.pressed.connect(_on_back_pressed)
	
	if game_over_popup:
		var try_btn = game_over_popup.find_child("TryAgainButton", true, false)
		if not try_btn: try_btn = game_over_popup.find_child("TextureButton", true, false)
		if try_btn:
			if not try_btn.pressed.is_connected(restart_level):
				try_btn.pressed.connect(restart_level)
				
	if win_next_btn:
		if not win_next_btn.pressed.is_connected(next_level):
			win_next_btn.pressed.connect(next_level)
			
	if win_replay_btn:
		if not win_replay_btn.pressed.is_connected(restart_level):
			win_replay_btn.pressed.connect(restart_level)

func _process(delta):
	if game_active and not is_paused and time_left > 0:
		time_left -= delta
		update_timer_label()
		if time_left <= 0:
			trigger_game_over()

func start_level():
	game_active = true
	is_paused = false
	
	grid_holder.visible = true
	
	if pause_button: 
		pause_button.visible = true
		pause_button.texture_normal = icon_pause
	
	if win_popup: win_popup.visible = false
	if game_over_popup: game_over_popup.visible = false
	if submenu_popup: submenu_popup.visible = false 
	
	background.texture = bg_off
	ceiling_light.texture = light_off
	
	match Global.current_level:
		1:
			grid_cols = 3
			grid_rows = 2
		2:
			grid_cols = 3
			grid_rows = 3
		3:
			grid_cols = 4
			grid_rows = 3
		4:
			grid_cols = 4
			grid_rows = 4
		5:
			grid_cols = 5
			grid_rows = 6
		_:
			grid_cols = 3 
			grid_rows = 3
	
	var base_time = 105.0 
	var extra_time = (Global.current_level - 1) * 30.0
	time_left = base_time + extra_time
	
	update_timer_label()
	generate_grid()
	
	randomize()
	var shuffles = 10 + (Global.current_level * 5)
	for i in range(shuffles):
		var rr = randi() % grid_rows
		var rc = randi() % grid_cols
		toggle_neighbors(rr, rc)

func _on_pause_pressed():
	if GlobalAudio: GlobalAudio.play_click()
	is_paused = !is_paused
	if pause_button:
		pause_button.texture_normal = icon_play if is_paused else icon_pause

func _on_back_pressed():
	if GlobalAudio: GlobalAudio.play_click()
	get_tree().change_scene_to_file("res://Scenes/LevelSelect.tscn")

func update_timer_label():
	if timer_label:
		var minutes = floor(time_left / 60)
		var seconds = int(time_left) % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]
		timer_label.modulate = Color.RED if time_left < 10 else Color.WHITE
		
		var screen_size = get_viewport_rect().size
		timer_label.position.x = screen_size.x - timer_label.size.x - 20

func trigger_game_over():
	game_active = false
	time_left = 0
	update_timer_label()
	if game_over_popup:
		game_over_popup.visible = true

func toggle_menu():
	if submenu_popup:
		if GlobalAudio: GlobalAudio.play_click()
		submenu_popup.visible = !submenu_popup.visible
		is_paused = submenu_popup.visible
		if pause_button:
			pause_button.texture_normal = icon_play if is_paused else icon_pause

func generate_grid():
	for child in grid_holder.get_children():
		child.queue_free()
	grid = []
	grid_holder.scale = Vector2.ZERO 
	grid_holder.scale = Vector2(1, 1)
	
	for r in range(grid_rows):
		var row_array = []
		for c in range(grid_cols):
			var s = switch_scene.instantiate()
			grid_holder.add_child(s)
			s.position = Vector2(c * base_spacing, r * base_spacing)
			s.setup(r, c)
			s.switch_clicked.connect(_on_switch_logic)
			row_array.append(s)
		grid.append(row_array)
	
	var raw_width = (grid_cols - 1) * base_spacing + 128 
	var raw_height = (grid_rows - 1) * base_spacing + 128
	
	var screen_size = get_viewport_rect().size
	var max_allowed_width = screen_size.x * 0.9 
	var max_allowed_height = screen_size.y * 0.60 
	
	var scale_factor = 1.0
	if raw_width > max_allowed_width:
		scale_factor = max_allowed_width / raw_width
	if raw_height * scale_factor > max_allowed_height:
		scale_factor = max_allowed_height / raw_height
		
	grid_holder.scale = Vector2(scale_factor, scale_factor)
	
	var final_width = raw_width * grid_holder.scale.x
	var final_height = raw_height * grid_holder.scale.y
	
	grid_holder.position.x = (screen_size.x / 2) - (final_width / 2)
	grid_holder.position.y = (screen_size.y / 2) - (final_height / 2) + 80 

func center_ui_elements():
	var screen_size = get_viewport_rect().size
	
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.size = screen_size
	background.position = Vector2.ZERO
	
	if ceiling_light:
		ceiling_light.position.x = (screen_size.x / 2) - (ceiling_light.size.x / 2)
		ceiling_light.position.y = 20 
	
	if timer_label:
		timer_label.position.x = screen_size.x - timer_label.size.x - 20
		timer_label.position.y = 20
		
		if pause_button:
			pause_button.position.x = screen_size.x - pause_button.size.x - 20
			pause_button.position.y = timer_label.position.y + timer_label.size.y + 10

	if menu_button:
		menu_button.position = Vector2(20, 20)
		
	if submenu_popup:
		submenu_popup.position = Vector2(20, 70)
		
	if game_over_popup:
		game_over_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
		var title = game_over_popup.find_child("TitleImage", true, false)
		if title:
			title.position.x = (screen_size.x / 2) - (title.size.x / 2)
			title.position.y = (screen_size.y / 2) - 150
		var btn = game_over_popup.find_child("TryAgainButton", true, false)
		if not btn: btn = game_over_popup.find_child("TextureButton", true, false)
		if btn:
			btn.position.x = (screen_size.x / 2) - (btn.size.x / 2)
			btn.position.y = (screen_size.y / 2) + 60
			
	if win_popup:
		win_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		if win_message_img:
			win_message_img.position.x = (screen_size.x / 2) - (win_message_img.size.x / 2)
			win_message_img.position.y = (screen_size.y / 2) - 150 
			
		var hbox = win_popup.find_child("HBoxContainer", true, false)
		if hbox:
			hbox.set_anchors_preset(Control.PRESET_CENTER)
			hbox.position.y += 100 

func _on_switch_logic(r, c):
	if game_active and not is_paused:
		toggle_neighbors(r, c)
		check_win()

func toggle_neighbors(r, c):
	toggle_switch(r, c)
	toggle_switch(r + 1, c)
	toggle_switch(r - 1, c)
	toggle_switch(r, c + 1)
	toggle_switch(r, c - 1)

func toggle_switch(r, c):
	if r >= 0 and r < grid_rows and c >= 0 and c < grid_cols:
		grid[r][c].toggle()

func check_win():
	var all_on = true
	for r in range(grid_rows):
		for c in range(grid_cols):
			if not grid[r][c].is_on:
				all_on = false
				break
	
	if all_on:
		game_active = false
		background.texture = bg_on
		ceiling_light.texture = light_on
		
		# --- PLAY WIN SOUND (LOUDER) ---
		var player = AudioStreamPlayer.new()
		player.stream = win_sound
		player.volume_db = 15.0  # Increased Volume here! (+15dB)
		add_child(player)
		player.play()
		
		grid_holder.visible = false
		if pause_button: pause_button.visible = false
			
		await get_tree().create_timer(1.5).timeout
		
		if win_popup:
			var img_path = "res://Assets/M" + str(Global.current_level) + ".png"
			if FileAccess.file_exists(img_path):
				if win_message_img:
					win_message_img.texture = load(img_path)
			
			win_popup.visible = true

func restart_level():
	if GlobalAudio: GlobalAudio.play_click()
	start_level()

func next_level():
	if GlobalAudio: GlobalAudio.play_click()
	if Global.current_level < 5: 
		Global.current_level += 1
		start_level()
	else:
		get_tree().change_scene_to_file("res://Scenes/LevelSelect.tscn")
