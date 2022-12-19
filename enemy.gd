extends KinematicBody2D

const gravity = 500
const move_speed = 50

var velocity = Vector2(-move_speed, 0)

func _physics_process(delta):
	
	velocity.y += gravity * delta
	if is_on_floor() and velocity.y > 0:
		velocity.y = 0
	
	move_and_slide(velocity, Vector2(0, -1))

func damage(amount):
	if $health_bar.value - amount <= 0:
		queue_free()
		return
	
	$health_bar.value -= amount
