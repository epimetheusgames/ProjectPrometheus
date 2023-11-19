extends Node2D

var speed = 0.5
var direction = speed
var gravity = 0.5
var velocity = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.x = direction 
	velocity.y += gravity
	
	var left_collision = $RayCastLeft.get_collider()
	var right_collision = $RayCastRight.get_collider()
	var down_collision = $RayCastDown.get_collider()
	var down_collision_2 = $RayCastDown2.get_collider()
	
	if left_collision != null && direction == -speed:
		direction = speed
		$DrillSprite.scale.x = 1
	elif right_collision != null && direction == speed:
		direction = -speed
		$DrillSprite.scale.x = -1
	
	if down_collision != null || down_collision_2 != null:
		velocity.y = -0.05
		
	position += velocity

func _on_jump_hurt_box_area_entered(area):
	if area.name == "PlayerHurtbox":
		area.get_parent().jump_vel = 8
		area.get_parent().rocket_jump_vel = 8
		area.get_parent().velocity.x = -area.get_parent().velocity.x
		
		if area.get_parent().velocity.x > 0:
			area.get_parent().velocity.x = 4
		if area.get_parent().velocity.x < 0:
			area.get_parent().velocity.x = -4
		if area.get_parent().velocity.x == 0:
			area.get_parent().velocity.x = 4 * (direction * (1 / speed))
		
		area.get_parent().jump()
		area.get_parent().jump_vel = 4
		area.get_parent().rocket_jump_vel = 6
