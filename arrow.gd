extends RigidBody2D

var damage = 5

func _on_arrow_body_entered(body):
	if not body.has_method("damage_santa"):
		queue_free()
		return
	
	body.damage_santa(damage)
	queue_free()
