extends TileMapLayer

@export var bpm: float = 120.0

var blue_blocks = []
var pink_blocks = []

var blue_active = true;

var beat_interval = 300.0/bpm;
var time = 0.0;

func _ready() -> void:
	for cell in get_used_cells():
		var data = get_cell_tile_data(cell)
		var color = data.get_custom_data("Color")
		if color == "blue":
			blue_blocks.push_front(cell)
		elif color == "pink":
			pink_blocks.push_front(cell)
	_update_blocks()

func _process(delta: float) -> void:
	time += delta
	if time >= beat_interval:
		time -= beat_interval
		blue_active = !blue_active
		_update_blocks()

func _update_blocks():
	var onColor = Color(1.0, 1.0, 1.0, 1.0)
	var offColor = Color(0.25, 0.25, 0.25, 1.0)
	if blue_active:
		for cell in blue_blocks:
			get_cell_tile_data(cell).modulate = onColor
		for cell in pink_blocks:
			get_cell_tile_data(cell).modulate = offColor
	else:
		for cell in blue_blocks:
			get_cell_tile_data(cell).modulate = offColor
		for cell in pink_blocks:
			get_cell_tile_data(cell).modulate = onColor
