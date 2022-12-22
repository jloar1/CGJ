extends StaticBody2D

var max_health = 100.0
var health = 100.0

var armor = 0.0

func damage_santa(amount):
	if health - amount <= 0:
		get_tree().change_scene("res://DeathScreen.tscn")
		return
	
	health -= (amount * (1 - (armor / 100)))
	$health_bar.value = health / max_health
