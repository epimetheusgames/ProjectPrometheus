extends Node2D


var velocity = Vector2.ZERO
var exploded = false

func _ready():
	$ExplosionHitbox/CollisionShape2D.shape = $ExplosionHitbox/CollisionShape2D.shape.duplicate()

func _process(delta):
	if !exploded:
		velocity.y += 0.2
		position += velocity * delta * 60 * 0.5

func _on_explosion_hitbox_body_entered(body):
	if !exploded:
		exploded = true
		$GPUParticles2D.emitting = true
		$ExplosionHitbox/CollisionShape2D.shape.radius = 32
		$Timer.start()
		$Sprite2D.visible = false

func _on_timer_timeout():
	queue_free()

func _on_timer_2_timeout():
	$ExplosionHitbox/CollisionShape2D.disabled = true
