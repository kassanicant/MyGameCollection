extends TextureButton

signal switch_clicked(row, col)

var is_on: bool = false
var grid_row: int
var grid_col: int

var tex_on = preload("res://Assets/Switch On.png")
var tex_off = preload("res://Assets/Switch Off.png")

@onready var sound_player = $SwitchSound

func setup(r, c):
	grid_row = r
	grid_col = c
	update_visuals()

func toggle():
	is_on = !is_on
	update_visuals()

func update_visuals():
	texture_normal = tex_on if is_on else tex_off

func _pressed():
	# Play sound locally when clicked
	if sound_player.stream:
		sound_player.play()
	
	switch_clicked.emit(grid_row, grid_col)
