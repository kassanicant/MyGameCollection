extends Control

# Paths to your specific game scenes. 
# UPDATE THESE PATHS to match exactly where you saved your game scenes.
var simon_says_scene = "res://Games/SimonSays/SimonSaysMain.tscn"
var lights_on_scene = "res://Games/LightsOn/LightsOnMain.tscn"

func _ready():
	# This ensures the mouse is visible when returning to the menu
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Signal function for Simon Says Button
func _on_btn_simon_pressed():
	get_tree().change_scene_to_file(simon_says_scene)

# Signal function for Lights On Button
func _on_btn_lights_pressed():
	get_tree().change_scene_to_file(lights_on_scene)

# Signal function for Quit Button
func _on_btn_quit_pressed():
	get_tree().quit()
