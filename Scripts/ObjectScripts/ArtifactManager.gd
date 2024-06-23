# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|
# Code for collectible artifact.                                                                         |
# -------------------------------------------------------------------------------------------------------|


extends Area2D

# Unique ID which must be set in the editor.
@export var uid = 0

func _ready():
	print(uid, " ", get_parent().level)
	
	# Play sprite animation on ready.
	$AnimatedSprite2D.play("Animation")

	# Destroy artifact if it's already been collected (checks for UID inside
	# of the save files).
	if get_parent().get_parent().get_parent().get_node("SaveLoadFramework").load_data(get_parent().slot)[4].has(str(uid)):
		queue_free()

func _on_area_entered(area):
	# Collect artifact!
	if area.name == "PlayerHurtbox":
		get_parent().get_parent().get_parent().get_node("SaveLoadFramework").collect_artifact(get_parent().slot, uid)
		get_parent().points += 15
		$GPUParticles2D.emitting = true
		$AnimatedSprite2D.visible = false
		$DestroyTimer.start()
		
		var total_artifacts = get_parent().get_parent().get_parent().get_node("SaveLoadFramework").load_achievement_tracking("total_artifacts") + 1
		get_parent().get_parent().get_parent().get_node("SaveLoadFramework").save_achievement_tracking("total_artifacts", total_artifacts)
		
		if total_artifacts == 1:
			get_parent().get_parent().get_parent().get_node("SaveLoadFramework").save_achievement("col_1_artifact")
		if total_artifacts == 10:
			get_parent().get_parent().get_parent().get_node("SaveLoadFramework").save_achievement("col_10_artifacts")

# After the artifact has been collected, destroy it.
func _on_destroy_timer_timeout():
	queue_free()
