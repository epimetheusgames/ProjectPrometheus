extends CharacterBody2D


@export var start_direction = 1
@export var health = 3
@onready var speed = 0.5
@onready var direction = speed * start_direction
var gravity = 0.5
var enabled = false

func _physics_process(delta):
	velocity.x = direction
	velocity.y += gravity
	
	var left_collision = $RayCastLeft.get_collider()
	var right_collision = $RayCastRight.get_collider()
	var down_collision = $RayCastDown.get_collider()
	var down_collision_2 = $RayCastDown2.get_collider()
	var ext_down_collision = $ExtRaycastDownLeft.get_collider()
	var ext_down_collision_2 = $ExtRaycastDownRight.get_collider()
	
	if !ext_down_collision && ext_down_collision_2 && direction == -speed:
		var node_with_name = Node.new()
		node_with_name.name = "Drill worked!"
		left_collision = node_with_name
	if !ext_down_collision_2 && ext_down_collision && direction == speed:
		var node_with_name = Node.new()
		node_with_name.name = "Drill worked!"
		right_collision = node_with_name
	
	if left_collision != null && left_collision.name != "Player" && direction == -speed:
		direction = speed
		$ARobotSprite.scale.x = 1
		
	elif right_collision != null && right_collision.name != "Player" && direction == speed:
		direction = -speed
		$ARobotSprite.scale.x = -1
	
	if down_collision != null || down_collision_2 != null:
		velocity.y = -0.05
	
	position += velocity * (delta * 60)
