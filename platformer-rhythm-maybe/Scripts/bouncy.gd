extends Area2D

var power = 350;

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.velocity.y = -power
		body.dashes = 1;
