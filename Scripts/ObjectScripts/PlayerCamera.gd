extends Camera2D


@onready var border_original_scale = $ScreenBorder.scale
@onready var camera_original_scale = zoom
var open_dialogue = false
var was_open = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$FPSCounter.text = "FPS: " + str(Engine.get_frames_per_second())
	$ScreenBorder.scale = border_original_scale * (camera_original_scale / zoom)
			
	was_open = open_dialogue
	
	if get_parent().get_parent().boss:
		$BossBar.visible = true

	if Input.is_action_just_pressed("esc"):
		$DialogueBoxContainer.visible = false
		open_dialogue = false
		get_tree().paused = false
		
		for child in $DialogueBoxContainer.get_children():
			child.queue_free()
			
	var original_scale = Vector2(1, 1)
	var original_pos = Vector2(-234, 111)
	
	$FPSCounter.position = original_pos * (4 / zoom.x)
	$FPSCounter.scale = original_scale * (4 / zoom.x)
			
	original_scale = Vector2(1, 1)
	original_pos = Vector2(99, -136)
	
	$PointsCounter.position = original_pos * (4 / zoom.x)
	$PointsCounter.scale = original_scale * (4 / zoom.x)
	
	original_scale = Vector2(1, 1)
	original_pos = Vector2(-234, -134)
	
	$TimeCounter.position = original_pos * (4 / zoom.x)
	$TimeCounter.scale = original_scale * (4 / zoom.x)

func open_dialogue_box():
	get_tree().paused = true
	$DialogueBoxContainer.visible = true
	open_dialogue = true
