extends KinematicBody2D

const gravity = 500
const strength = 8

var arrow = load("res://arrow.tscn")

var max_health = 8.0
var health = 8.0
var move_speed = 80.0
var damage = 5.0

var velocity = Vector2(0, 0)

func _physics_process(delta):
	
	velocity.x = lerp(velocity.x, -move_speed, 10 * delta)
	
	velocity.y += gravity * delta
	if is_on_floor() and velocity.y > 0:
		velocity.y = 0
	
	if $attack_cooldown.is_stopped():
		if attack():
			$attack_cooldown.start()
		
		move_and_slide(velocity, Vector2(0, -1))

func attack():
	if $attack_raycast.get_collider() == null:
		return false
	
	var arrow_instance = arrow.instance()
	get_parent().add_child(arrow_instance)
	arrow_instance.position = global_position + Vector2(-32, 0)
	arrow_instance.linear_velocity = Vector2(-200, 0)
	arrow_instance.damage = damage
	return true

func damage(amount, knockback):
	if health - amount <= 0:
		if get_parent().has_method("update_enemies"):
			get_parent().update_enemies(strength)
		queue_free()
		return
	
	health -= amount
	$health_bar.value = (health * 1.0) / max_health
	velocity.x = knockback


func _on_attack_cooldown_timeout():
	if not attack():
		$attack_cooldown.stop()
