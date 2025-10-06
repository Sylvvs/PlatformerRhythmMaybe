extends Area2D

@onready var scene_handler = get_node("/root/Node")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var scene_name = scene_handler.current_scene.name
		Fadelayer.fade_in(0.3).connect("finished", Callable(scene_handler, "load_scene").bind(scene_name))
