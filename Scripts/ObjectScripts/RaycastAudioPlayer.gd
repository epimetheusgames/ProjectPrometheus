extends AudioStreamPlayer


var delay = 0

func _process(delta):
	if delay > 0:
		delay -= delta
	
	if delay == 0 && playing:
		play()
