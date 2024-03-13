extends AudioStreamPlayer


@export var optional_save_load: Node2D

func play():
	if optional_save_load:
		optional_save_load.start_special_music()
	else:
		get_parent().get_parent().
