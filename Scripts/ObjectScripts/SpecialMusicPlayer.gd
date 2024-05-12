extends AudioStreamPlayer


@export var optional_save_load: Node2D
@export var auto_play = false


func play_audio():
	get_tree().get_root().get_node("Root").get_node("SaveLoadFramework").start_special_music()
	play()
	
func _ready():
	if auto_play:
		play_audio()
