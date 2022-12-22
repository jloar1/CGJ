extends Node2D

var present = load("res://present.tscn")
var warrior = load("res://warrior.tscn")
var archer = load("res://archer.tscn")

var rng = RandomNumberGenerator.new()

var paused = false

var cannon_angle = 0
var cannon_strength = 1

var wave = 0
var total_enemies = 0
var enemies_spawned = 0
var enemies_left = 0

var enemy_type = 1

var upgrade_pool = []

# all the stuff that can be upgraded
var damage = 6.0
var big_damage = 30.0
var santa_armor = 0.0
var present_despawn = 0.5
var present_knockback = 100.0
var ability_cooldown = 30.0
var heart_health = 10.0

func _ready():
	rng.randomize()
	
	reset_buttons()
	
	# common upgrades
	for upgrade in range(0, 10):
		upgrade_pool.append(1)
		upgrade_pool.append(2)
		upgrade_pool.append(3)
		upgrade_pool.append(4)
		upgrade_pool.append(5)
		upgrade_pool.append(6)
		#upgrade_pool.append(7)
		#upgrade_pool.append(8)
	
	start_wave()

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and $cannon/cooldown.is_stopped() and not paused:
		var present_instance = present.instance()
		add_child(present_instance)
		present_instance.position = $cannon/axle.global_position + (Vector2.RIGHT.rotated(cannon_angle) * 200)
		present_instance.linear_velocity = Vector2.RIGHT.rotated(cannon_angle) * cannon_strength * 1.5
		present_instance.damage_amount = damage
		present_instance.knockback = present_knockback
		present_instance.get_node("destroy_timer").wait_time = present_despawn
		$cannon/cooldown.start()

func _input(event):
	if paused:
		return
	if event is InputEventMouseMotion:
		cannon_strength = clamp((event.position - $cannon/axle.global_position).length(), 200, 500)
		cannon_angle = clamp((event.position - $cannon/axle.global_position).angle(), -PI/2, 0)
		$cannon/axle.rotation = cannon_angle

func reset_buttons():
	var buttons = [$upgrade_menu/center/vbox/upgrade1, $upgrade_menu/center/vbox/upgrade2, $upgrade_menu/center/vbox/upgrade3]
	
	for button in buttons:
		button.texture_normal = null
		button.texture_hover = null
		button.texture_pressed = null
		
		button.get_node("label").text = "N/A"
		
		var cons = button.get_signal_connection_list("pressed")
		for con in cons:
			button.disconnect(con.signal, con.target, con.method)
		
		button.connect("pressed", self, "next_wave")

func next_wave():
	paused = false
	$blur.z_index = -10
	$upgrade_menu.visible = false
	reset_buttons()
	start_wave()

# here are all the upgrade functions
func upgrade1():
	damage += 0.6
	big_damage += 3.0

func upgrade2():
	$cannon/cooldown.wait_time *= 0.9

func upgrade3():
	$santa.max_health += 10.0
	$santa.health += 10.0
	$santa/health_bar.value = $santa.health / $santa.max_health

func upgrade4():
	$santa.armor += 5.0

func upgrade5():
	present_despawn += 0.25

func upgrade6():
	present_knockback += 0.1

func upgrade7():
	ability_cooldown *= 0.9

func upgrade8():
	heart_health += 1

func start_wave():
	wave += 1
	total_enemies = 5 * (wave - 1) + 10
	enemies_spawned = 0
	$wave_control/spawn_timer.wait_time = clamp(2 * exp(-0.06 * (wave - 1)), 0.1, 2)
	
	$wave_control/wave.text = "Wave " + str(wave)
	$wave_control/enemies_left.value = 0
	$wave_control/spawn_timer.start()

func spawn_enemy():
	if wave >= 5:
		 enemy_type = rng.randi_range(1, 2)
	
	if enemy_type == 2:
		if enemies_spawned + 8 <= total_enemies:
			return archer.instance()
		enemy_type -= 1
	
	if enemy_type == 1:
		return warrior.instance()
	
	return null

func _on_spawn_timer_timeout():
	if enemies_spawned >= total_enemies:
		return
	
	var instance = spawn_enemy()
	
	enemies_spawned += instance.strength
	
	add_child(instance)
	instance.position = $wave_control/enemy_spawn_position.global_position
	
	instance.max_health *= 1 + (0.25 * (wave / 5))
	instance.health = instance.max_health
	instance.move_speed *= 1 + (0.25 * (wave / 5))

func update_button(current_button, current_upgrade):
	if current_upgrade <= 8:
		current_button.texture_normal = load("res://art/common_upgrade.png")
		current_button.texture_hover = load("res://art/common_upgrade_hover.png")
		current_button.texture_pressed = load("res://art/common_upgrade_press.png")
	
	if current_upgrade == 1:
		current_button.get_node("label").text = "Increase gift damage by 10%"
		current_button.connect("pressed", self, "upgrade1")
	elif current_upgrade == 2:
		current_button.get_node("label").text = "Decrease attack cooldown by 10%"
		current_button.connect("pressed", self, "upgrade2")
	elif current_upgrade == 3:
		current_button.get_node("label").text = "Increase Santa's health by 10%"
		current_button.connect("pressed", self, "upgrade3")
	elif current_upgrade == 4:
		current_button.get_node("label").text = "Increase Santa's armor by 5"
		current_button.connect("pressed", self, "upgrade4")
	elif current_upgrade == 5:
		current_button.get_node("label").text = "Gifts last 0.25 seconds longer before despawning"
		current_button.connect("pressed", self, "upgrade5")
	elif current_upgrade == 6:
		current_button.get_node("label").text = "Increase gift knockback by 10%"
		current_button.connect("pressed", self, "upgrade6")

func select_upgrade():
	paused = true
	
	var rand_upgrade1 = rng.randi_range(0, upgrade_pool.size() - 1)
	var rand_upgrade2 = rng.randi_range(0, upgrade_pool.size() - 1)
	var rand_upgrade3 = rng.randi_range(0, upgrade_pool.size() - 1)
	while upgrade_pool[rand_upgrade2] == upgrade_pool[rand_upgrade1]:
		rand_upgrade2 = rng.randi_range(0, upgrade_pool.size())
	while upgrade_pool[rand_upgrade3] == upgrade_pool[rand_upgrade1] or upgrade_pool[rand_upgrade3] == upgrade_pool[rand_upgrade2]:
		rand_upgrade3 = rng.randi_range(0, upgrade_pool.size())
	
	update_button($upgrade_menu/center/vbox/upgrade1, upgrade_pool[rand_upgrade1])
	update_button($upgrade_menu/center/vbox/upgrade2, upgrade_pool[rand_upgrade2])
	update_button($upgrade_menu/center/vbox/upgrade3, upgrade_pool[rand_upgrade3])
	
	$blur.z_index = 10
	$upgrade_menu.visible = true

func update_enemies(enemy_strength):
	$wave_control/enemies_left.value += (enemy_strength * 1.0) / total_enemies
	
	enemies_left = -enemy_strength
	
	for e in get_children():
		if e.has_method("damage"):
			enemies_left += e.strength
	
	if enemies_spawned >= total_enemies and enemies_left == 0:
		$wave_control/spawn_timer.stop()
		$wave_control/wave_end.start()
		return
