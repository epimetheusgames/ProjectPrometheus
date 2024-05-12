extends Area2D


@onready var biodome_music = preload("res://Assets/Audio/Music/BiodomeMusic.ogg")
@onready var save_load_framework = get_tree().get_root().get_node("Root").get_node("SaveLoadFramework")


func _on_area_entered(area):
	if area.name == "PlayerHurtbox" && !save_load_framework.get_node("SpecialAudioPlayer").playing:
		save_load_framework.get_node("SpecialAudioPlayer").stream = biodome_music
		save_load_framework.get_node("SpecialAudioPlayer").play()
		save_load_framework.get_node("SpecialAudioPlayer").volume_db = -7
		save_load_framework.start_special_music()

func _on_area_exited(area):
	if area.name == "PlayerHurtbox" && save_load_framework.get_node("SpecialAudioPlayer").playing && !get_parent().cannot_stop_special_music:
		save_load_framework.end_special_music()
