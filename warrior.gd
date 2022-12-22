extends KinematicBody2D

const gravity = 500
const strength = 5

var max_health = 10.0
var health = 10.0
var move_speed = 60.0
var damage = 2.0

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
	
	if not $attack_raycast.get_collider().has_method("damage_santa"):
		return false
	
	$attack_raycast.get_collider().damage_santa(damage)
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
