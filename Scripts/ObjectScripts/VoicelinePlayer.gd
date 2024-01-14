extends Node2D


var hazard_deaths_this_level = 0

@onready var voicelines = {
	"1TutorialA2": load("res://Assets/Audio/Voicelines/1TutorialA2.mp3"),
	"1TutorialADeath1": load("res://Assets/Audio/Voicelines/1TutorialADeath1.ogg"),
	"1TutorialADeath2": load("res://Assets/Audio/Voicelines/1TutorialADeath2.ogg"),
	"1TutorialADeath3": load("res://Assets/Audio/Voicelines/1TutorialADeath3.ogg"),
}

func play_voiceline(voiceline_name):
	$VoicelineContainer.playing = false
	$VoicelineContainer.stream = voicelines[voiceline_name]
	$VoicelineContainer.playing = true

func death_by_hazard():
	hazard_deaths_this_level += 1
	
	if get_parent().current_level_ind == 0:
		if hazard_deaths_this_level == 1:
			play_voiceline("1TutorialADeath1")
		if hazard_deaths_this_level == 2:
			play_voiceline("1TutorialADeath2")
		if hazard_deaths_this_level == 3:
			play_voiceline("1TutorialADeath3")
