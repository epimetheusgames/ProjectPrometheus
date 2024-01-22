extends CharacterBody2D


@onready var graphics_efficiency = get_parent().graphics_efficiency
@onready var player = get_parent().get_node("Player").get_node("Player")
@onready var loaded_bullet = preload("res://Objects/StaticObjects/DroneBullet.tscn")
@onready var loaded_mele = preload("res://Objects/StaticObjects/AttackMele.tscn")
@onready var loaded_drill = preload("res://Objects/StaticObjects/Drill.tscn")
@onready var loaded_bomb = preload("res://Objects/StaticObjects/Exploder.tscn")
@onready var start_pos = position 

@export var health = 100

var dropped_enemies = false

func shoot_bullet(pos):
	var direction_to_player = (player.position - position + player.get_parent().position - pos).normalized()
	var bullet_to_add = loaded_bullet.instantiate()
	bullet_to_add.position = position + pos
	bullet_to_add.velocity = direction_to_player * 3
	bullet_to_add.graphics_efficiency = graphics_efficiency
	get_parent().add_child(bullet_to_add)
	
func spawn_mele(pos):
	var mele_to_add = loaded_mele.instantiate()
	mele_to_add.position = position + pos
	get_parent().add_child(mele_to_add)
	
func spawn_drill(pos):
	var drill_to_add = loaded_drill.instantiate()
	drill_to_add.position = position + pos
	drill_to_add.disable_hitbox_when_dead = true
	get_parent().add_child(drill_to_add)
	
func spawn_bomb(pos, vel_scale):
	var bomb_to_add = loaded_bomb.instantiate()
	bomb_to_add.position = position + pos
	var direction_to_player = (player.position - position + player.get_parent().position - pos).normalized()
	bomb_to_add.velocity.x = direction_to_player.x * vel_scale
	get_parent().add_child(bomb_to_add)

func _on_new_explosion_timer_timeout():
	if player.position.distance_to(position) < 600 && (player.current_ability == "RocketBoost" || player.current_ability == "Grapple"):
		spawn_bomb($BossShootPosition3.position, 5)
		spawn_bomb($BossShootPosition4.position, -5)

func _on_new_bullet_timer_timeout():
	if player.position.distance_to(position) < 600 && player.current_ability == "ArmGun":
		shoot_bullet($BossShootPosition.position)
		shoot_bullet($BossShootPosition2.position)

func _on_boss_hurtbox_area_entered(area):
	if area.name == "PlayerBulletHurter":
		health -= 1
		
		if health < 40:
			health += 0.5
		
		player.get_parent().get_node("Camera").get_node("BossBar").value = health
		
func _process(delta):
	if !player.current_ability == "Weapon":
		dropped_enemies = false
	elif !dropped_enemies:
		dropped_enemies = true
		spawn_mele($MeleSpawn.position)
		spawn_mele($MeleSpawn2.position)
		
		if health < 50:
			spawn_drill($MeleSpawn3.position)
			
	if health < 50 && position.distance_to((start_pos + $FiftyPercentPos.position)) > 10:
		get_parent().get_node("BossHook1").get_node("Area2D").get_node("CollisionShape2D").disabled = false
		position += (start_pos + $FiftyPercentPos.position - position).normalized()
