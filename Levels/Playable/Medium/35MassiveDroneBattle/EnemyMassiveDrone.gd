extends StaticBody2D


@onready var loaded_exploder = preload("res://Objects/StaticObjects/Exploder.tscn")
@onready var loaded_physics_boss = preload("res://Objects/StaticObjects/PhysicsBigDrone.tscn")
@onready var explosion_positions = [
	$ExplosionPositions/Node2D,
	$ExplosionPositions/Node2D2,
	$ExplosionPositions/Node2D3,
	$ExplosionPositions/Node2D4,
	$ExplosionPositions/Node2D5,
	$ExplosionPositions/Node2D6,
	$ExplosionPositions/Node2D7,
	$ExplosionPositions/Node2D8,
	$ExplosionPositions/Node2D9,
	$ExplosionPositions/Node2D10,
	$ExplosionPositions/Node2D11,
	$ExplosionPositions/Node2D12,
	$ExplosionPositions/Node2D13,
	$ExplosionPositions/Node2D14,
	$ExplosionPositions/Node2D15,
	$ExplosionPositions/Node2D16,
	$ExplosionPositions/Node2D17,
	$ExplosionPositions/Node2D18,
	$ExplosionPositions/Node2D19,
	$ExplosionPositions/Node2D20,
	$ExplosionPositions/Node2D21,
	$ExplosionPositions/Node2D22,
	$ExplosionPositions/Node2D23,
	$ExplosionPositions/Node2D24,
	$ExplosionPositions/Node2D25,
	$ExplosionPositions/Node2D26,
	$ExplosionPositions/Node2D27,
]

@export var acceleration = 0.0015

var flying_toward_player = false
var velocity = Vector2.ZERO
var health = 2


func _process(delta):
	if flying_toward_player:
		velocity.x -= acceleration * delta * 60
	
	position += velocity * delta * 60

func _on_hurt_box_area_entered(area):
	if area.name == "ExplosionArea":
		for explosion_position in explosion_positions:
			var instantiated_exploder = loaded_exploder.instantiate()
			instantiated_exploder.position = $ExplosionPositions.position + explosion_position.position + position
			instantiated_exploder.get_node("ExplosionArea").queue_free()
			
			# Call deferred because we can't add a child while flushing collision detection.
			get_parent().call_deferred("add_child", instantiated_exploder)
	
		health -= 1
		if health <= 0:
			$KillTimer.start()

func _on_player_ship_activator_area_area_entered(area):
	if area.name == "PlayerHurtbox":
		flying_toward_player = true

func _on_kill_timer_timeout():
	queue_free()
	
	var instantiated_physics_boss = loaded_physics_boss.instantiate()
	instantiated_physics_boss.set_queued_pos = true
	instantiated_physics_boss.queued_position = position + $ExplosionPositions.position
	get_parent().call_deferred("add_child", instantiated_physics_boss)


