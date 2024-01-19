extends Node2D


var hazard_deaths_this_level = 0
var weapons_used_this_level = 0
var drone_deaths_this_level = 0
var one_tutorial_c_grapple_swing_deaths_this_level = 0

@onready var voicelines = {
}

var queue = []
var already_played_voicelines = []

func _process(delta):
	if $VoicelineContainer.playing == false && len(queue) > 0:
		play_voiceline(queue[-1])
		queue.pop_back()

func play_voiceline(voiceline_name):
	if !voiceline_name in already_played_voicelines:
		already_played_voicelines.append(voiceline_name)
		$VoicelineContainer.playing = false
		#$VoicelineContainer.stream = voicelines[voiceline_name]
		$VoicelineContainer.playing = true
	
func add_to_queue(voiceline_name):
	queue.append(voiceline_name)

func death_by_hazard():
	pass

func death_by_drone():
	pass
			
func one_tutorial_c_grapple_swing():
	one_tutorial_c_grapple_swing_deaths_this_level += 1
	
	if one_tutorial_c_grapple_swing_deaths_this_level == 3:
		#add_to_queue("1TutorialCGrappleDeath6")
		pass

func get_out_weapon():
	pass
