extends Control

# --- CRITICAL: DRAG AND DROP THESE NODES IN THE INSPECTOR ---
@export var back_button: TextureButton
@export var countdown_label: Label
@export var score_label: Label
@export var message_label: Label
@export var buttons: Array[TextureButton] 
@export var sounds: Array[AudioStreamPlayer]
@export var turn_timer: Timer
@export var game_over_sound: AudioStreamPlayer
@export var button_grid: GridContainer 

# --- GAME OVER NODES ---
@export var game_over_panel: Panel      
@export var final_score_label: Label    
@export var restart_button: TextureButton 
@export var main_menu_button: TextureButton 
@export var game_over_texture: TextureRect 

# Game Variables
var sequence = []
var current_step = 0
var score = 0
var is_player_turn = false
var time_limit = 5.0 
var valid_button_indices = []

func _ready():
	get_tree().paused = false
	
	# HIDE PANEL ON SCENE LOAD
	if game_over_panel: game_over_panel.hide()
	if countdown_label: countdown_label.hide()
	
	# Connect Buttons
	if back_button: back_button.pressed.connect(_on_back_button_pressed)
	if restart_button: restart_button.pressed.connect(_on_restart_button_pressed)
	if main_menu_button: main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
	# Initialize buttons and valid indices
	for i in range(buttons.size()):
		if buttons[i] != null:
			buttons[i].show()
			valid_button_indices.append(i)
			if not buttons[i].pressed.is_connected(_on_color_button_pressed.bind(i)):
				buttons[i].pressed.connect(_on_color_button_pressed.bind(i))
	
	if turn_timer:
		turn_timer.timeout.connect(_on_timeout)
		
	start_countdown()

# --- UI ACTIONS ---

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")

# --- GAME FLOW ---

func start_countdown():
	if game_over_panel: game_over_panel.hide()
	if button_grid: button_grid.hide()
		
	# Disable buttons during countdown
	for btn in buttons:
		if btn != null: btn.disabled = true
		
	await get_tree().create_timer(0.5).timeout
	
	if countdown_label:
		countdown_label.show()
		countdown_label.text = "3"
		await get_tree().create_timer(1.0).timeout
		countdown_label.text = "2"
		await get_tree().create_timer(1.0).timeout
		countdown_label.text = "1"
		await get_tree().create_timer(1.0).timeout
		countdown_label.text = "GO!"
		await get_tree().create_timer(0.5).timeout
		countdown_label.hide()
		start_game()
	else:
		start_game()

func start_game():
	score = 0
	sequence.clear()
	time_limit = 5.0 # Reset speed on new game
	if score_label: score_label.text = "0"
	
	# Ensure labels are visible at start of game
	if score_label: score_label.show()
	if message_label: message_label.show()
	
	if button_grid: button_grid.show()
	start_next_round()

func start_next_round():
	is_player_turn = false
	current_step = 0
	
	# Disable buttons before playing the sequence
	for btn in buttons:
		if btn != null: btn.disabled = true 
		
	if valid_button_indices.size() > 0:
		var random_valid_index = valid_button_indices[randi() % valid_button_indices.size()]
		sequence.append(random_valid_index)
	
	await get_tree().create_timer(0.5).timeout
	for index in sequence:
		highlight_button(index)
		await get_tree().create_timer(0.6).timeout
		
		if !is_player_turn and current_step == -1: return 

	is_player_turn = true
	if message_label: message_label.text = "Your Turn"
	
	# Enable buttons for the player's turn
	for btn in buttons:
		if btn != null: btn.disabled = false 
		
	if turn_timer: turn_timer.start(time_limit)

func highlight_button(index):
	if index < buttons.size() and buttons[index] != null:
		var btn = buttons[index]
		var old_color = btn.modulate
		btn.modulate = Color(2, 2, 2)
		if index < sounds.size() and sounds[index] != null: 
			sounds[index].play()
		await get_tree().create_timer(0.3).timeout
		btn.modulate = old_color

func _on_color_button_pressed(index):
	if not is_player_turn: return
	
	if index < sounds.size() and sounds[index] != null: 
		sounds[index].play()
		
	if index == sequence[current_step]:
		if turn_timer: turn_timer.start(time_limit)
		current_step += 1
		
		if current_step >= sequence.size():
			
			# Add 1 point
			score += 1 
			
			# 🛑 SPEED CHECK: Increase speed if score is a multiple of 3
			if score > 0 and score % 3 == 0:
				# Decrease time limit by 0.2s, but not below 0.5s
				time_limit = max(0.5, time_limit - 0.2) 
			
			if score_label: score_label.text = " " + str(score)
			is_player_turn = false
			if turn_timer: turn_timer.stop()
			for btn in buttons: if btn: btn.disabled = true
			await get_tree().create_timer(1.0).timeout
			start_next_round()
	else:
		# INCORRECT GUESS: STOP GAME IMMEDIATELY
		game_over() 
		return

func _on_timeout():
	if message_label: message_label.text = "Time Out!"
	# TIMEOUT: STOP GAME IMMEDIATELY
	game_over()

# --- GAME OVER EXECUTION ---
func game_over():
	# Only execute game over logic once
	if is_player_turn == false and current_step == -1: return

	is_player_turn = false
	current_step = -1 # Flag game over state
	
	if turn_timer: turn_timer.stop()
	if game_over_sound: game_over_sound.play() 
	
	# Hide Score and Turn Labels
	if score_label: score_label.hide()
	if message_label: message_label.hide()
	
	# Disable all input buttons
	for btn in buttons: 
		if btn: btn.disabled = true
		
	# Hide the playing grid
	if button_grid:
		button_grid.hide()

	# SHOW GAME OVER PANEL
	if game_over_panel:
		game_over_panel.show()
		
		if final_score_label:
			final_score_label.text = "FINAL SCORE: " + str(score)
		
		if game_over_texture:
			game_over_texture.show()
