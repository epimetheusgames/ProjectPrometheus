# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# ---------------------------------------------PlayerCamera.gd-------------------------------------------|
# Handle UI which follows the camera.                                                                    |
# -------------------------------------------------------------------------------------------------------|


extends Camera2D


# Original scale of (now probably unnecesary) screen border.
@onready var border_original_scale = $ScreenBorder.scale

# Original scale of camera.
@onready var camera_original_scale = zoom

# Something to do with the pause menu I think.
var open_dialogue = false

# Same here.
var was_open = false


func _ready():
	set_objective_text(get_tree().get_root().get_node("Root").get_node("SaveLoadFramework").current_objective)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Set frames per second text.
	$FPSCounter.text = "FPS: " + str(Engine.get_frames_per_second())
	
	# Set scale of (now probably unnecesary) screen border.
	$ScreenBorder.scale = border_original_scale * (camera_original_scale / zoom)
	
	# What's this about.
	was_open = open_dialogue
	
	# Set boss bar to visible if this is a boss fight.
	if get_parent().get_parent().boss && !get_parent().get_parent().dont_show_bossbar:
		$BossBar.visible = true

	# Seriously what is this about.
	if Input.is_action_just_pressed("esc"):
		$DialogueBoxContainer.visible = false
		open_dialogue = false
		get_tree().paused = false
		
		for child in $DialogueBoxContainer.get_children():
			child.queue_free()
	
	# Get the text to stay in the corners of the screen even when the camera
	# zooms.
	var original_scale = Vector2(0.25, 0.25)
	var original_pos = Vector2(-236, 117)
	
	$FPSCounter.position = original_pos * (4 / zoom.x)
	$FPSCounter.scale = original_scale * (4 / zoom.x)
			
	original_scale = Vector2(0.25, 0.25)
	original_pos = Vector2(61, -133)
	
	$PointsCounter.position = original_pos * (4 / zoom.x)
	$PointsCounter.scale = original_scale * (4 / zoom.x)
	
	original_scale = Vector2(0.25, 0.25)
	original_pos = Vector2(-236, -134)
	
	$TimeCounter.position = original_pos * (4 / zoom.x)
	$TimeCounter.scale = original_scale * (4 / zoom.x)
	
	original_scale = Vector2(1.35, 1.35)
	original_pos = Vector2(0, -122)
	
	$ObjectiveBoxManager.scale = original_scale * (4 / zoom.x)
	$ObjectiveBoxManager.position = original_pos * (4 / zoom.x)

# Whar.
func open_dialogue_box():
	get_tree().paused = true
	$DialogueBoxContainer.visible = true
	open_dialogue = true

# Big function name, goes to the next level.
func _on_level_transition_animation_player_animation_finished(anim_name):
	if anim_name == "CloseLevel":
		get_parent().get_parent().get_node("NextLevel").add_level()

func set_objective_text(text):
	$ObjectiveBoxManager/ObjectiveBoxText.text = text
	get_tree().get_root().get_node("Root").get_node("SaveLoadFramework").current_objective = text
