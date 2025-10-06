extends Node

var current_scene: Node = null

func _ready() -> void:
	load_scene("MossyCave")

func load_scene(scene_name: String) -> void:
	var path = "res://Scenes/Levels/%s.tscn" % scene_name
	var scene_res = load(path)
	if scene_res == null:
		push_error("Failed to load scene: " + path)
		return

	if current_scene != null:
		current_scene.queue_free()
		call_deferred("_deferred_load_scene", scene_res)
		return 

	_deferred_load_scene(scene_res)


func _deferred_load_scene(scene_res):
	current_scene = scene_res.instantiate()
	add_child(current_scene)

	var logic_node = current_scene.get_node_or_null("Logic")
	if logic_node != null:
		var areas = logic_node.get_children()
		for area in areas:
			if area is Area2D:
				area.body_entered.connect(func(body):
					_on_area_entered(area, body)
					)
	Fadelayer.fade_out(0.1)

func _on_area_entered(area, body) -> void:
	if not body.is_in_group("Player"):
		return
	
	if not area.next_scene:
		push_error("Area2D has no next_scene!!!")
		return
	
	var next_scene = area.get("next_scene")
	Fadelayer.fade_in(0.1).connect("finished", Callable(self, "load_scene").bind(next_scene))
	
