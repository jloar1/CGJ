extends Node2D

var present = load("res://present.tscn")
var enemy = load("res://enemy.tscn")

var cannon_angle = 0

func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseMotion:
		cannon_angle = clamp((event.position - $cannon/axle.global_position).angle(), -PI/2, 0)
		$cannon/axle.rotation = cannon_angle
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var present_instance = present.instance()
			add_child(present_instance)
			present_instance.position = $cannon/axle.global_position + (Vector2.RIGHT.rotated(cannon_angle) * 200)
			present_instance.linear_velocity = Vector2.RIGHT.rotated(cannon_angle) * 500

func _on_enemy_spawn_timer_timeout():
	var enemy_instance = enemy.instance()
	add_child(enemy_instance)
	enemy_instance.position = $enemy_spawn_position.position
