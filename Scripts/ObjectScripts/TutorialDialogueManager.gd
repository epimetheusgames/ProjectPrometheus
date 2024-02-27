extends Node2D


var displaying_dialogue = false
var displaying_ind = -1
var displaying_opacity = 0
var dialogue_displaying = null
var fading_in = false
var fading_out = false

func enter_tutorial_area(tutorial_box_ind):
	if tutorial_box_ind == 1:
		dialogue_displaying = $ItemSwitcherDialogue1
		
	dialogue_displaying.visible = true
	displaying_dialogue = true
	displaying_ind = tutorial_box_ind
	fading_in = true
	dialogue_displaying.modulate.a = 0
		
func _process(delta):
	if displaying_dialogue:
		if Input.is_action_just_pressed("interact"):
			fading_out = true
			
		if displaying_opacity < 1 && fading_in:
			displaying_opacity += 0.05 * delta * 60
		elif fading_in:
			fading_in = false
			
		if displaying_opacity > 0 && fading_out:
			displaying_opacity -= 0.05 * delta * 60
		elif fading_out:
			$ItemSwitcherDialogue1.visible = false
			displaying_dialogue = false
			dialogue_displaying = null
			displaying_ind = -1
			fading_out = false
			return
		
		dialogue_displaying.modulate.a = displaying_opacity
