extends RigidBody2D

var damage_amount = 6.0
var knockback = 100.0

func _on_present_body_entered(body):
	if body is RigidBody2D:
		return
	
	if body.has_method('damage'):
		body.damage(damage_amount, knockback)
		queue_free()
		return
	
	if not $destroy_timer.is_stopped():
		return
	
	$destroy_timer.start()

func _on_destroy_timer_timeout():
	queue_free()
