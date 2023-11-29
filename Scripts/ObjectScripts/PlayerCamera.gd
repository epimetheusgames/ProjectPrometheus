extends Camera2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$FPSCounter.text = "FPS: " + str(Engine.get_frames_per_second())
