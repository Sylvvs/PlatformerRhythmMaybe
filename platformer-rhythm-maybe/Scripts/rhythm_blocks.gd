extends TileMapLayer

@export var bpm: float = 120.0

@onready var collision = load("res://Scenes/Logic/BlockCollision.tscn")
@onready var bouncy = load("res://Scenes/Logic/Bouncy.tscn")
@onready var player = $"../Player"
@onready var audio_player = $"../AudioStreamPlayer"

var blue_blocks = []
var pink_blocks = []

var blue_active = true;
var pending_color = ""

var beat_interval = 160.0/bpm;
var time = 0.8;

func _ready() -> void:
	audio_player.play()
	
	for cell in get_used_cells():
		var data = get_cell_tile_data(cell)
		var color = data.get_custom_data("Color") if data.has_custom_data("Color") else ""
		var type = data.get_custom_data("Type") if data.has_custom_data("Type") else ""
		if color == "blue":
			blue_blocks.push_front(cell)
		elif color == "pink":
			pink_blocks.push_front(cell)
		
		if type != "":
			_handle_type(cell, type)
		
	_turn_on("blue" if blue_active else "pink")
	_turn_off("blue" if !blue_active else "pink")

var bouncy_blocks = [];

func _handle_type(cell, type):
	match type:
		"bouncy":
			var block = bouncy.instantiate()
			get_parent().add_child.call_deferred(block)
			bouncy_blocks.push_front(block)
			block.position = map_to_local(cell)


func _process(delta: float) -> void:
	time += delta
	if time >= beat_interval:
		time -= beat_interval
		blue_active = !blue_active
		
		_turn_off("blue" if !blue_active else "pink")
		
		if _player_inside_target_color(pending_color):
			pending_color = "blue" if blue_active else "pink"
		else:
			_turn_on("blue" if blue_active else "pink")
	
	if pending_color != "" and not _player_inside_target_color(pending_color):
		_turn_on(pending_color)
		pending_color = ""

var collision_blocks = [];

func _turn_off(color) -> void:
	var offColor = Color(0.25, 0.25, 0.25, 1.0)
	if color == "blue":
		for cell in blue_blocks:
			get_cell_tile_data(cell).modulate = offColor
	else:
		for cell in pink_blocks:
			get_cell_tile_data(cell).modulate = offColor

	for block in collision_blocks:
		block.queue_free()
	collision_blocks.clear()

func _turn_on(color):
	var onColor = Color(1.0, 1.0, 1.0, 1.0)
	if color == "blue":
		for cell in blue_blocks:
			get_cell_tile_data(cell).modulate = onColor
			_add_collision(cell)
	else:
		for cell in pink_blocks:
			get_cell_tile_data(cell).modulate = onColor
			_add_collision(cell)

func _add_collision(pos):
	var block = collision.instantiate()
	get_parent().add_child.call_deferred(block)
	collision_blocks.push_front(block)
	block.position = map_to_local(pos)

func _player_inside_target_color(color):
	if color == "":
		color = "blue" if blue_active else "pink"
	
	var blocks = blue_blocks if color == "blue" else pink_blocks
	
	for cell in blocks:
		var cell_pos = map_to_local(cell)
		var cell_rect = Rect2(cell_pos - Vector2(8,8), Vector2(16, 16))
		
		if cell_rect.intersects(player.get_global_rect()):
			return true;
	return false
