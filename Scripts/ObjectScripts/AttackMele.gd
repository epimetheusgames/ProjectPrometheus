extends CharacterBody2D


var speed = 0.15
var max_speed = 0.8
var jump_vel = 6
var gravity = 0.5
var attacking = false
var friction_force = 1.2
@onready var player = get_parent().get_node("Player").get_node("Player")
@export var health = 4
var direction = 0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta * 60

	if health > 0:
		var down_col = $RayCastDown.get_collider() 
		var left_col = $RayCastLeft.get_collider()
		var right_col = $RayCastRight.get_collider()
		var top_left_col = $RayCastLeftTop.get_collider()
		var top_right_col = $RayCastRightTop.get_collider()
		
		direction = 0

		if player.position.x - position.x > 0:
			direction = 1
		if player.position.x - position.x < 0:
			direction = -1
			
		var jump = ((left_col && direction == -1 && !"Player" in left_col.name) || (right_col && direction == 1 && !"Player" in right_col.name)) && (left_col if direction == -1 else right_col)
		var player_near = (left_col && "Player" in left_col.name) || (right_col && "Player" in right_col.name)
		
		if is_on_floor() && jump:
			velocity.y = -jump_vel
			
		if (down_col && "Player" in down_col.name):
			velocity.y = -jump_vel
			velocity.x = -direction * speed * 2
			_on_jump_hurt_box_area_entered(down_col.get_node("PlayerHurtbox"))
			
		if player_near && $AttackTimer.time_left <= 0 && $AttackResetTimer.time_left <= 0:
			$AttackTimer.start()
		
		if direction && !player_near && !$AttackResetTimer.time_left > 0:
			velocity.x += direction * speed
			
		if attacking:
			$JumpHurtBox/CollisionShape2D.disabled = false
		else:
			$JumpHurtBox/CollisionShape2D.disabled = true
		
		# Don't apply friction if the player is moving.
		if is_on_floor() && (absf(velocity.x) > max_speed):
			velocity.x /= friction_force
		
		position += velocity
	else:
		$DeadCollision.disabled = false
		$AliveCollision.disabled = true

	move_and_slide()

func _on_attack_timer_timeout():
	$AttackStopTimer.start()
	attacking = true

func _on_attack_stop_timer_timeout():
	$AttackResetTimer.start()
	attacking = false

func _on_attack_reset_timer_timeout():
	$AttackTimer.start()

func _on_jump_hurt_box_area_entered(area):
	if area.name == "PlayerHurtbox" && health > 0:
		area.get_parent().jump_vel = 5
		area.get_parent().rocket_jump_vel = 5
		area.get_parent().velocity.x = -area.get_parent().velocity.x
		
		area.get_parent().velocity.x = 4 * direction
		
		area.get_parent().jump()
		area.get_parent().jump_vel = 4
		area.get_parent().rocket_jump_vel = 6

func _on_hurt_box_area_entered(area):
	if area.name == "PlayerHurtbox" && health > 0:
		if area.get_parent().get_node("DashStopCooldown").time_left > 0:
			health -= 1
			
			if health == 0:
				area.get_parent().get_node("BulletBadHurtcooldown").stop()
				area.get_parent().get_node("PlayerAnimation").modulate = Color.WHITE
