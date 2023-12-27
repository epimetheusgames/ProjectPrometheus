extends Node2D

@export var start_direction = 1
@export var health = 3
@onready var speed = 0.5
@onready var direction = speed * start_direction
var gravity = 0.5
var velocity = Vector2.ZERO

func _ready():
	if direction == speed:
		$DrillAnimation.scale.x = 1
	elif direction == -speed:
		$DrillAnimation.scale.x = -1
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health > 0:
		velocity.x = direction
		velocity.y += gravity
		
		var left_collision = $RayCastLeft.get_collider()
		var right_collision = $RayCastRight.get_collider()
		var down_collision = $RayCastDown.get_collider()
		var down_collision_2 = $RayCastDown2.get_collider()
		
		if left_collision != null && left_collision.name != "Player" && direction == -speed:
			direction = speed
			$JumpHurtBox/CollisionShape2D2.disabled = false
			$JumpHurtBox/CollisionShape2D3.disabled = false
			$DrillAnimation.scale.x = 1
			$DrillBreakOverlay.scale.x = 1
		elif right_collision != null && right_collision.name != "Player" && direction == speed:
			direction = -speed
			$JumpHurtBox/CollisionShape2D2.disabled = false
			$JumpHurtBox/CollisionShape2D3.disabled = false
			$DrillAnimation.scale.x = -1
			$DrillBreakOverlay.scale.x = -1
		
		if down_collision != null || down_collision_2 != null:
			velocity.y = -0.05
			$DrillAnimation.play("Moving")
		elif direction != 0:
			$DrillAnimation.play("Moving")
		else:
			$DrillAnimation.play("Idle")
			
		if health == 3:
			$DrillBreakOverlay.play("None")
		if health == 2:
			$DrillBreakOverlay.play("Break1")
		if health == 1:
			$DrillBreakOverlay.play("Break2")
			
		position += velocity * (delta * 60)
	else:
		$DrillBreakOverlay.play("Break3")
		$DrillAnimation.play("Idle")

func _on_jump_hurt_box_area_entered(area):
	var no_damage = false
	
	if area.name == "PlayerHurtbox" && health > 0:
		if area.get_parent().get_node("NewDashCooldown").time_left > 0:
			health -= 1
			no_damage = true
		
		area.get_parent().jump_vel = 5
		area.get_parent().rocket_jump_vel = 5
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
