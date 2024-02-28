extends Node2D


var velocity = Vector2.ZERO
var exploded = false
@export var no_damage = false
@onready var player = get_parent().get_node("Player").get_node("Player")

func _ready():
	$ExplosionHitbox/CollisionShape2D.shape = $ExplosionHitbox/CollisionShape2D.shape.duplicate()

func _on_explosion_hitbox_body_entered(body):
	if !exploded:
		exploded = true
		$GPUParticles2D.emitting = true
		$ExplosionHitbox/CollisionShape2D.shape.radius = 32
		$Timer.start()
		$Timer2.start()
		$Sprite2D.visible = false
	
		var direction_to_player = (player.position - position).normalized()
		player.velocity = direction_to_player * 5

func _on_timer_timeout():
	queue_free()

func _on_timer_2_timeout():
	$ExplosionHitbox.queue_free()
