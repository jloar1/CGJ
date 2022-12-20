extends Node2D

var present = load("res://present.tscn")
var enemy = load("res://warrior.tscn")

var cannon_angle = 0

var wave = 0
var total_enemies = 0
var enemies_spawned = 0
var enemies_left = 0

func _ready():
	start_wave()

func _input(event):
	if event is InputEventMouseMotion:
		cannon_angle = clamp((event.position - $cannon/axle.global_position).angle(), -PI/2, 0)
		$cannon/axle.rotation = cannon_angle
	
	if not $cannon/cooldown.is_stopped():
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var present_instance = present.instance()
			add_child(present_instance)
			present_instance.position = $cannon/axle.global_position + (Vector2.RIGHT.rotated(cannon_angle) * 200)
			present_instance.linear_velocity = Vector2.RIGHT.rotated(cannon_angle) * 500
			$cannon/cooldown.start()

func _on_enemy_spawn_timer_timeout():
	var enemy_instance = enemy.instance()
	add_child(enemy_instance)
	enemy_instance.position = $enemy_spawn_position.position

func start_wave():
	wave += 1
	total_enemies = 5 * (wave - 1) + 10
	enemies_spawned = 0
	$wave_control/spawn_timer.wait_time = clamp(2 * exp(-0.1 * (wave - 1)), 0.01, 2)
	
	$wave_control/wave.text = "Wave " + str(wave)
	$wave_control/enemies_left.value = 0
	$wave_control/spawn_timer.start()

func _on_spawn_timer_timeout():
	if enemies_spawned >= total_enemies:
		return
	
	var instance = enemy.instance()
	add_child(instance)
	instance.position = $wave_control/enemy_spawn_position.global_position
	instance.max_health *= 1 + (0.25 * (wave / 5))
	instance.health = instance.max_health
	instance.move_speed *= 1 + (0.25 * (wave / 5))
	enemies_spawned += 5

func update_enemies(enemy_strength):
	$wave_control/enemies_left.value += (enemy_strength * 1.0) / total_enemies
	
	enemies_left = -enemy_strength
	
	for e in get_children():
		if e.has_method("damage"):
			enemies_left += e.strength
	
	if enemies_spawned >= total_enemies and enemies_left == 0:
		$wave_control/spawn_timer.stop()
		start_wave()
		return
