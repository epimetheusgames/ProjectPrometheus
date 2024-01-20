extends CharacterBody2D


const speed = 150
@export var player: CharacterBody2D

func _physics_process(_delta: float):
	var dir = to_local($NavigationAgent2D.get_next_path_position()).normalized()
	var intended_velocity = dir * speed
	$NavigationAgent2D.set_velocity(intended_velocity)
	
func _on_timer_timeout():
	$NavigationAgent2D.target_position = player.global_position

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
