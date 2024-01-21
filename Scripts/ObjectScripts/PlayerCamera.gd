extends Camera2D


@onready var border_original_scale = $ScreenBorder.scale
@onready var camera_original_scale = zoom


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$FPSCounter.text = "FPS: " + str(Engine.get_frames_per_second())
	$ScreenBorder.scale = border_original_scale * (camera_original_scale / zoom)
	
	if get_parent().get_parent().boss:
		$BossBar.visible = true
