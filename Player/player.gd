extends CharacterBody2D

var movement_speed = 40.0
var hp = 80

#attack
var shadowSpear = preload("res://Player/Attack/shadow_spear.tscn")

#attackNodes
@onready var shadowSpearTimer = get_node("%ShadowSpearTimer")
@onready var shadowSpearAttackTimer = get_node("%ShadowSpearAttackTimer")

#shadowSpear
var shadowspear_ammo = 0
var shadowspear_baseammo = 1
var shadowspear_attackspeed = 1.5
var shadowspear_level = 1

#enemy related
var enemy_close = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

func _ready():
	attack()

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

func _on_hurt_box_hurt(damage):
	hp -= damage
	print(hp)


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
