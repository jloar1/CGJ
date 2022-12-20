extends StaticBody2D


func damage_santa(amount):
	if $health_bar.value - amount <= 0:
		get_tree().reload_current_scene()
		queue_free()
		return
	
	$health_bar.value -= amount
