extends CharacterBody2D

var movement_speed = 40.0
var hp = 80
var last_movement = Vector2.UP

var experience = 0
var experience_level = 1
var collected_experience = 0

#attack
var shadowSpear = preload("res://Player/Attack/shadow_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javalin.tscn")

#attackNodes
@onready var shadowSpearTimer = get_node("%ShadowSpearTimer")
@onready var shadowSpearAttackTimer = get_node("%ShadowSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")

#UPGRADES
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed  = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0

#Tornado
var tornado_ammo = 0
var tornado_baseammo = 1
var tornado_attackspeed = 3
var tornado_level = 1

#shadowSpear
var shadowspear_ammo = 0
var shadowspear_baseammo = 1
var shadowspear_attackspeed = 1.5
var shadowspear_level = 1

#Javelin
var javelin_ammo = 3
var javelin_level = 1

#enemy related
var enemy_close = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lbllevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOption")
@onready var sndLevelUp = get_node("%snd_levelup")
@onready var itemOptions = preload("res://Utility/item_option.tscn")

func _ready():
	attack()
	set_expbar(experience,calculate_experiencecap())

func _physics_process(delta):
	movement()
	
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	if mov.x > 0:
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false
		
	if mov != Vector2.ZERO:
		last_movement = mov
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else: 
				sprite.frame += 1
			walkTimer.start()
			
		
	
	velocity = mov.normalized()*movement_speed
	move_and_slide()
	
func attack():
	if shadowspear_level > 0:
		shadowSpearTimer.wait_time = shadowspear_attackspeed
		if shadowSpearTimer.is_stopped():
			shadowSpearTimer.start()
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	if javelin_level > 0:
		spawn_javelin()
func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= damage
	print(hp)

func _on_tornado_timer_timeout() -> void:
	tornado_ammo += tornado_baseammo
	tornadoAttackTimer.start()

func _on_tornado_attack_timer_timeout() -> void:
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else: 
			tornadoAttackTimer.stop()
	
func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawn = javelin_ammo - get_javelin_total
	while calc_spawn > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawn -= 1
		

func _on_shadow_spear_timer_timeout() -> void:
	shadowspear_ammo += shadowspear_baseammo
	shadowSpearAttackTimer.start()


func _on_shadow_spear_attack_timer_timeout() -> void:
	if shadowspear_ammo > 0:
		var shadowspear_attack = shadowSpear.instantiate()
		shadowspear_attack.position = position
		shadowspear_attack.target = get_random_target()
		shadowspear_attack.level = shadowspear_level
		add_child(shadowspear_attack)
		shadowspear_ammo -= 1
		if shadowspear_ammo > 0:
			shadowSpearAttackTimer.start()
		else: 
			shadowSpearAttackTimer.stop()
	
		
func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP
		


func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)


func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)
	
func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required:
		collected_experience -= exp_required - experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		levelup()
		calculate_experience(0)
	else:
		experience += collected_experience
		collected_experience = 0
	set_expbar(experience,exp_required)
		
func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap + 95 * (experience_level-19)*8
	else:
		exp_cap = 225 + (experience_level - 39) * 12
	
	return exp_cap
	
func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value
	
func levelup():
	sndLevelUp.play()
	lbllevel.text = str("Level:", experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(220,50),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var option = 0
	var optionmax = 3
	while option < optionmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		option += 1
	get_tree().paused = true
	
func upgrade_character(upgrade):
	var option_children = upgradeOptions.get_children()
	for i  in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800,50)
	get_tree().paused = false
	calculate_experience(0)

func get_random_item():
	var dblist = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades: #exp
			pass
		elif i in upgrade_options: #exp
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "items": #exxp
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0: #exp
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					pass
				else:
					dblist.append(i)
		else:
				dblist.append(i)
	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null
