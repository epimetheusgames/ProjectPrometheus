extends Node2D


var hazard_deaths_this_level = 0
var weapons_used_this_level = 0
var drone_deaths_this_level = 0
var one_tutorial_c_grapple_swing_deaths_this_level = 0

@onready var voicelines = {
	"1TutorialA2": load("res://Assets/Audio/Voicelines/1TutorialA2.mp3"),
	"1TutorialADeath1": load("res://Assets/Audio/Voicelines/1TutorialADeath1.ogg"),
	"1TutorialADeath2": load("res://Assets/Audio/Voicelines/1TutorialADeath2.ogg"),
	"1TutorialADeath3": load("res://Assets/Audio/Voicelines/1TutorialADeath3.ogg"),
	"1TutorialACompleteLevel1": load("res://Assets/Audio/Voicelines/1TutorialACompleteLevel1.ogg"),
	"1TutorialAGetsOutWeapon1": load("res://Assets/Audio/Voicelines/1TutorialAGetsOutWeapon1.ogg"),
	"1TutorialAGetsOutWeapon2": load("res://Assets/Audio/Voicelines/1TutorialAGetsOutWeapon2.ogg"),
	"1TutorialADiesToDrone1": load("res://Assets/Audio/Voicelines/1TutorialADiesToDrone1.ogg"),
	"1TutorialB1": load("res://Assets/Audio/Voicelines/1TutorialB1.ogg"),
	"1TutorialBPistonSmasherDeath1": load("res://Assets/Audio/Voicelines/1TutorialBPisonSmasherDeath1.ogg"),
	"1TutorialC1": load("res://Assets/Audio/Voicelines/1TutorialC1.ogg"),
	"1TutorialCGrappleDeath1": load("res://Assets/Audio/Voicelines/1TutorialCGrappleDeath1.ogg"),
	"1TutorialCGrappleDeath2": load("res://Assets/Audio/Voicelines/1TutorialCGrappleDeath2.ogg"),
	"1TutorialCGrappleDeath3": load("res://Assets/Audio/Voicelines/1TutorialCGrappleDeath3.ogg"),
	"1TutorialCGrappleDeath4": load("res://Assets/Audio/Voicelines/1TutorialCGrappleDeath4.ogg"),
	"1TutorialCGrappleDeath6": load("res://Assets/Audio/Voicelines/1TutorialCGrappleDeath6.ogg"),
	"1TutorialCGrappleDeath7": load("res://Assets/Audio/Voicelines/1TutorialCGrappleDeath7.ogg"),
	"1TutorialCGrappleDeath8": load("res://Assets/Audio/Voicelines/1TutorialCGrappleDeath8.ogg"),
	"1TutorialCGrappleSwingFirstTry1": load("res://Assets/Audio/Voicelines/1TutorialCGrappleSwingFirstTry1.ogg"),
	"2EasyLaserDeath1": load("res://Assets/Audio/Voicelines/2EasyLaserDeath1.ogg"),
	"2EasyLaserDeath2": load("res://Assets/Audio/Voicelines/2EasyLaserDeath2.ogg"),
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
		$VoicelineContainer.stream = voicelines[voiceline_name]
		$VoicelineContainer.playing = true
	
func add_to_queue(voiceline_name):
	queue.append(voiceline_name)

func death_by_hazard():
	hazard_deaths_this_level += 1
	
	if get_parent().current_level_ind == 0:
		if hazard_deaths_this_level == 1:
			add_to_queue("1TutorialADeath1")
		if hazard_deaths_this_level == 2:
			add_to_queue("1TutorialADeath2")
		if hazard_deaths_this_level == 3:
			add_to_queue("1TutorialADeath3")

func death_by_drone():
	drone_deaths_this_level += 1
	
	if get_parent().current_level_ind == 0:
		if drone_deaths_this_level == 1:
			add_to_queue("1TutorialADiesToDrone1")
			
func one_tutorial_c_grapple_swing():
	one_tutorial_c_grapple_swing_deaths_this_level += 1
	
	if one_tutorial_c_grapple_swing_deaths_this_level == 1:
		add_to_queue("1TutorialCGrappleDeath1")
	if one_tutorial_c_grapple_swing_deaths_this_level == 2:
		add_to_queue("1TutorialCGrappleDeath2")
	if one_tutorial_c_grapple_swing_deaths_this_level == 3:
		add_to_queue("1TutorialCGrappleDeath3")
	if one_tutorial_c_grapple_swing_deaths_this_level == 4:
		add_to_queue("1TutorialCGrappleDeath4")
	if one_tutorial_c_grapple_swing_deaths_this_level == 6:
		add_to_queue("1TutorialCGrappleDeath6")
	if one_tutorial_c_grapple_swing_deaths_this_level == 7:
		add_to_queue("1TutorialCGrappleDeath7")
	if one_tutorial_c_grapple_swing_deaths_this_level == 8:
		add_to_queue("1TutorialCGrappleDeath8")

func get_out_weapon():
	weapons_used_this_level += 1
	
	if get_parent().current_level_ind == 0:
		if weapons_used_this_level == 1:
			add_to_queue("1TutorialAGetsOutWeapon1")
		if weapons_used_this_level == 2:
			add_to_queue("1TutorialAGetsOutWeapon2")
