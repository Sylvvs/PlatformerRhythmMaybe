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
	
	current_scene = scene_res.instantiate()
	
	add_child(current_scene)
