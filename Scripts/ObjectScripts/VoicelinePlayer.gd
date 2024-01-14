extends Node2D


@onready var voicelines = {
	"1TutorialA2": preload("res://Assets/Audio/Voicelines/1TutorialA2.mp3")
}

func play_voiceline(voiceline_name):
	$VoicelineContainer.stream = voicelines[voiceline_name]
	$VoicelineContainer.play()
