extends Node2D

var present = load("res://present.tscn")

var cannon_angle = 0

func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseMotion:
		cannon_angle = clamp((event.position - $cannon/axle.global_position).angle(), -PI/2, 0)
		$cannon/axle.rotation = cannon_angle
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var instance = present.instance()
			add_child(instance)
			print(cannon_angle)
			instance.position = $cannon/axle.global_position + (Vector2.RIGHT.rotated(cannon_angle) * 200)
			instance.linear_velocity = Vector2.RIGHT.rotated(cannon_angle) * 500
