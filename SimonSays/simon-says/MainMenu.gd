extends Control

# --- DRAG AND DROP THESE IN THE INSPECTOR ---
@export var play_button: TextureButton
@export var quit_button: TextureButton

# --- NEW: DRAG AND DROP THESE IN THE INSPECTOR ---
@export var how_to_play_button: TextureButton # The button on the main screen
@export var how_to_play_panel: Panel          # The pop-up panel
@export var panel_back_button: TextureButton  # The close button on the panel

func _ready():
	get_tree().paused = false
	
	# 1. Connect Play Button
	if play_button:
		if not play_button.pressed.is_connected(_on_play_button_pressed):
			play_button.pressed.connect(_on_play_button_pressed)
	
	# 2. Connect Quit Button
	if quit_button:
		if not quit_button.pressed.is_connected(_on_quit_button_pressed):
			quit_button.pressed.connect(_on_quit_button_pressed)

	# 3. Connect NEW How To Play Button
	if how_to_play_button:
		if not how_to_play_button.pressed.is_connected(_on_how_to_play_button_pressed):
			how_to_play_button.pressed.connect(_on_how_to_play_button_pressed)

	# 4. Connect NEW Panel Back Button (Close button)
	if panel_back_button:
		if not panel_back_button.pressed.is_connected(_on_panel_back_button_pressed):
			panel_back_button.pressed.connect(_on_panel_back_button_pressed)
	
	# Ensure panel is hidden on startup, just in case
	if how_to_play_panel:
		how_to_play_panel.hide()


# --- EXISTING FUNCTIONS ---

func _on_play_button_pressed():
	# Make sure this path is correct: "res://GameScene.tscn"
	get_tree().change_scene_to_file("res://GameScene.tscn")

func _on_quit_button_pressed():
	get_tree().quit()


# --- NEW HOW TO PLAY FUNCTIONS ---

func _on_how_to_play_button_pressed():
	print("How To Play opened.")
	if how_to_play_panel:
		# Show the panel
		how_to_play_panel.show()
		# Optional: You can disable other main menu buttons here if you want
		if play_button: play_button.disabled = true
		if quit_button: quit_button.disabled = true

func _on_panel_back_button_pressed():
	print("How To Play closed.")
	if how_to_play_panel:
		# Hide the panel
		how_to_play_panel.hide()
		# Re-enable the main menu buttons
		if play_button: play_button.disabled = false
		if quit_button: quit_button.disabled = false
