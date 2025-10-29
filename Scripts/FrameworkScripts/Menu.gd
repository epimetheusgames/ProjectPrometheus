# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|
# Handles ALL the menus. I don't remember why I did it like this.                                        |
# -------------------------------------------------------------------------------------------------------|

extends Node2D

var character_type = 1
var slot_num = 1
var deactivated = false
var credits_open = false
@export var first = true
@export var max_artifacts = 26
@export var max_levels = 37
@onready var credits_instance = preload("res://Levels/Cutscenes/Credits.tscn")
var hovered_button = "PlayButton"
var selected_other_menu = false
var settings_menu_selected = false
var background_original_pos = Vector2.ZERO
var open_character_select_menu = false
var dont_fade = false
var start_game_on_next_animation_finish = false

@onready var slot_highlight_positions = [
	$Slot1HighlightPos,
	$Slot2HighlightPos,
	$Slot3HighlightPos,
	$Slot4HighlightPos,
	$Slot5HighlightPos,
]

@onready var slot_progress_bars = [
	$SlotProgressPercentage,
	$SlotProgressPercentage2,
	$SlotProgressPercentage3,
	$SlotProgressPercentage4,
	$SlotProgressPercentage5,
]

func deactivate():
	hide()
	deactivated = true
	# Deactivate all menu nodes!
	
func activate():
	show()
	deactivated = false 
	# Activate all menu nodes!
	
func _ready():
	if !dont_fade:
		Fade.fade_in()
	
	if first:
		modulate.a = 0.00001
	
	if name == "MainMenu":
		$AudioStreamPlayer.play()
		
	if name == "SettingsMenu":
		var global_data = get_tree().get_root().get_node("Root").get_node("SaveLoadFramework").load_data("global")
		$MusicSlider.value = global_data[1]
		$SFXSlider.value = global_data[2]
		$CheckButton.button_pressed = global_data[0]
		$Difficulty.button_pressed = global_data[3]
		$ShowFPS.button_pressed = global_data[4]
		$ShowPoints.button_pressed = global_data[5]
		$ShowSpeedrunTimer.button_pressed = global_data[6]
		
		# Compatability with versions < Beta 1.2
		if len(global_data) > 7:
			$WindowTypeSelection.selected = global_data[7]
			$VSyncModeSelection.selected = global_data[8]
			
			var index = global_data[8]
			
	if name == "StartGameMenu":
		$LevelSelect.set_value_no_signal(get_parent().get_parent().load_data($SlotSelect.value)[0] + 1)
		
	if name == "SelectSlotMenu":
		reload_percentages()
		_on_slot_1_button_up()

func _process(_delta):
	if modulate.a < 1:
		modulate.a *= 1.1
	
	if name == "SettingsMenu":
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), $MusicSlider.value if $MusicSlider.value > -40 else -10000)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), $SFXSlider.value if $SFXSlider.value > -40 else -10000)
		get_tree().get_root().get_node("Root").get_node("SaveLoadFramework").save_game(
			"[" + 
			str($CheckButton.button_pressed) + "," + 
			str($MusicSlider.value) + "," + 
			str($SFXSlider.value) + "," + 
			str($Difficulty.button_pressed) + "," + 
			str($ShowFPS.button_pressed) + "," + 
			str($ShowPoints.button_pressed) + "," + 
			str($ShowSpeedrunTimer.button_pressed) + "," +
			str($WindowTypeSelection.selected) + "," +
			str($VSyncModeSelection.selected) + "," +
			"]", "global")

		if settings_menu_selected:
			if hovered_button == "PlayButton":
				hovered_button = "Panel"
			
			$Panel.modulate.a = 0.188
			$Panel2.modulate.a = 0.188
			$Panel3.modulate.a = 0.188
			$Panel4.modulate.a = 0.188
			$Panel5.modulate.a = 0.188
			$Panel6.modulate.a = 0.188
			
			get_node(hovered_button).modulate.a = 0.525
			
			if Input.is_action_just_pressed("ui_down"):
				if hovered_button == "Panel":
					hovered_button = "Panel2"
				if hovered_button == "Panel4":
					hovered_button = "Panel3"
				if hovered_button == "Panel6":
					hovered_button = "Panel5"

	if name == "SelectLevelMenu":
		var loaded_data = get_parent().get_parent().load_data(get_parent().get_node("SelectSlotMenu").slot_num)
		$LevelSelect.max_value = loaded_data[0] + 1
		$LevelName.text = get_parent().get_parent().level_display_names[$LevelSelect.value - 1]
		
		get_parent().get_node("SelectSlotMenu").get_node("SelectLevelButton").text = "Level: " + str(int($LevelSelect.value))
		
		var undiscovered_secret_area_uids_on_current_level = false
		for uid_level_tuple in get_parent().get_parent().secret_area_data:
			if uid_level_tuple[1] == $LevelSelect.value - 1 && !str(uid_level_tuple[0]) in loaded_data[4].keys():
				undiscovered_secret_area_uids_on_current_level = true
		
		# Set color to blue, magic numbers are just the color, divide by
		# 255 to make the channel from 0 to 1 becuase that's what Godot supports
		if undiscovered_secret_area_uids_on_current_level:
			$LevelName.modulate = Color(0.7, 1, 0.9)
		else:
			$LevelName.modulate = Color(1, 1, 1)
		
	if name == "SelectSlotMenu":
		$Panel3.position += (slot_highlight_positions[slot_num - 1].position - $Panel3.position) * 0.3
	
	if name == "MainMenu":
		$PlayHighlight.visible = false
		$SettingsHighlight.visible = false
		$QuitHighlight.visible = false
		
		if Input.is_action_just_pressed("ui_down"):
			if hovered_button == "PlayHighlight":
				hovered_button = "SettingsHighlight"
			elif hovered_button == "SettingsHighlight":
				hovered_button = "QuitHighlight"
				
		if Input.is_action_just_pressed("ui_up"):
			if hovered_button == "SettingsHighlight":
				hovered_button = "PlayHighlight"
			elif hovered_button == "QuitHighlight":
				hovered_button = "SettingsHighlight"
				
		if Input.is_action_just_pressed("ui_accept"):
			if hovered_button == "PlayHighlight":
				_on_play_button_button_up()
			if hovered_button == "SettingsHighlight":
				_on_settings_button_button_up()
			if hovered_button == "QuitHighlight":
				_on_quit_button_button_up()
					
				selected_other_menu = true
			
		get_node(hovered_button).visible = true
		
		# Handle irregular screen sizes in menu.
		$Background.scale = Vector2(get_viewport_rect().size.y / 1080, get_viewport_rect().size.y / 1080)
		$Background.position = Vector2((get_viewport_rect().size.x - get_viewport_rect().size.x * $Background.scale.x) / 2, (get_viewport_rect().size.y - get_viewport_rect().size.y * $Background.scale.y) / 2)
		
		# Move the background towards the mouse, not sure if we want this.
		#$Background.position = background_original_pos + get_local_mouse_position() / 100

func _on_play_button_button_up():
	if !get_parent().demo_mode:
		get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play("SelectSlotMenuRiseFromDepthsAnimation")
	else:
		get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play("SelectCharacterMenuRiseFromDepthsAnimation")
	
func _on_settings_button_button_up():
	$SettingsMenu.visible = true
	$StartGameMenu.visible = false
	selected_other_menu = true

func _on_credits_button_button_up():
	if !credits_open:
		credits_open = true
		$Camera2D.enabled = false
		var instantiated_credits = credits_instance.instantiate()
		
		# Disable glow hopefully.
		instantiated_credits.modulate = Color(0.5, 0.5, 0.5, 1)
		instantiated_credits.position = Vector2(0, -10000)
		
		call_deferred("add_child", instantiated_credits)

func _on_quit_button_button_up():
	get_tree().quit()

func _on_settings_back_button_button_up():
	visible = false

func _on_start_button_up():
	var global_data = get_parent().get_parent().load_data("global")
	var local_slot_data = get_parent().get_parent().load_data(slot_num)
	
	_on_select_slot_cancel_button_up()
	
	if !local_slot_data[6]:
		get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play_backwards("SelectSlotMenuRiseFromDepthsAnimation")
		open_character_select_menu = true
		return
	
	get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play("SelectSlotMenuStartGameAnimation")

func reload_percentages():
	for slot in range(1, 6):
		var loaded_data = get_parent().get_parent().load_data(slot)
		
		# Get game percentage
		var num_artifacts_collected = loaded_data[4].size() 
		var num_levels_completed = loaded_data[0]
		var percentage_completed = ((num_artifacts_collected + num_levels_completed) / (max_artifacts + max_levels)) * 100
		
		if percentage_completed >= 100: # Greater than 100? HOW
			get_parent().get_parent().save_achievement("100_percent")
	
		slot_progress_bars[slot - 1].value = percentage_completed
		
		if percentage_completed == 0:
			slot_progress_bars[slot - 1].visible = false

func _on_type_1_button_down():
	character_type = 1

func _on_type_2_button_down():
	character_type = 2

func _on_type_3_button_down():
	character_type = 3

func _on_type_4_button_down():
	character_type = 4

func _on_clear_slot_button_up():
	get_parent().get_parent().save_data(0, 0, slot_num, 0, 0, {}, 0, false, 1, 1)
	reload_percentages()

func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()

func _on_slot_select_value_changed(value):
	get_parent().get_node("SelectLevelMenu").max_value = get_parent().get_parent().load_data($SlotSelect.value)[0] + 1
	get_parent().get_node("SelectLevelMenu").set_value_no_signal(get_parent().get_parent().load_data(value)[0] + 1)

func _on_play_button_mouse_entered():
	hovered_button = "PlayHighlight"

func _on_settings_button_mouse_entered():
	hovered_button = "SettingsHighlight"

func _on_credits_button_mouse_entered():
	hovered_button = "CreditsHighlight"

func _on_quit_button_mouse_entered():
	hovered_button = "QuitHighlight"

func _on_type_1_button_up():
	character_type = 1

func _on_type_2_button_up():
	character_type = 2

func _on_type_3_button_up():
	character_type = 3

func _on_type_4_button_up():
	character_type = 4

func _on_select_character_start_button_up():
	_on_cancel_button_up()
	var local_slot_data = get_parent().get_parent().load_data(get_parent().get_node("SelectSlotMenu").slot_num)
	
	get_parent().get_parent().save_data(local_slot_data[0], local_slot_data[1], get_parent().get_node("SelectSlotMenu").slot_num, local_slot_data[2], local_slot_data[3], local_slot_data[4], local_slot_data[5], true, character_type, local_slot_data[8])
	
	get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play("SelectCharacterMenuStartGameAnimation")
	
func _on_cancel_button_up():
	get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play_backwards("SelectCharacterMenuRiseFromDepthsAnimation")

func _on_select_slot_cancel_button_up():
	get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play_backwards("SelectSlotMenuRiseFromDepthsAnimation")
	
func _on_slot_1_button_up():
	var loaded_data = get_parent().get_parent().load_data(1)
	
	get_parent().get_node("SelectLevelMenu").get_node("LevelSelect").max_value = loaded_data[0] + 1
	get_parent().get_node("SelectLevelMenu").get_node("LevelSelect").set_value_no_signal(loaded_data[0] + 1)
	
	if len(loaded_data) > 8:
		get_parent().get_node("SelectDifficultyMenu").get_node("OptionButton").selected = loaded_data[8]
		get_parent().get_node("SelectDifficultyMenu")._on_option_button_item_selected(loaded_data[8])
	
	slot_num = 1
	
func _on_slot_2_button_up():
	var loaded_data = get_parent().get_parent().load_data(2)
	
	get_parent().get_node("SelectLevelMenu").get_node("LevelSelect").max_value = loaded_data[0] + 1
	get_parent().get_node("SelectLevelMenu").get_node("LevelSelect").set_value_no_signal(loaded_data[0] + 1)
	
	if len(loaded_data) > 8:
		get_parent().get_node("SelectDifficultyMenu").get_node("OptionButton").selected = loaded_data[8]
		get_parent().get_node("SelectDifficultyMenu")._on_option_button_item_selected(loaded_data[8])
		
	slot_num = 2
	
func _on_slot_3_button_up():
	var loaded_data = get_parent().get_parent().load_data(3)
	
	get_parent().get_node("SelectLevelMenu").get_node("LevelSelect").max_value = loaded_data[0] + 1
	get_parent().get_node("SelectLevelMenu").get_node("LevelSelect").set_value_no_signal(loaded_data[0] + 1)
	
	if len(loaded_data) > 8:
		get_parent().get_node("SelectDifficultyMenu").get_node("OptionButton").selected = loaded_data[8]
		get_parent().get_node("SelectDifficultyMenu")._on_option_button_item_selected(loaded_data[8])
		
	slot_num = 3
	
func _on_slot_4_button_up():
	var loaded_data = get_parent().get_parent().load_data(4)
	
	get_parent().get_node("SelectLevelMenu").get_node("LevelSelect").max_value = loaded_data[0] + 1
	get_parent().get_node("SelectLevelMenu").get_node("LevelSelect").set_value_no_signal(loaded_data[0] + 1)
	
	if len(loaded_data) > 8:
		get_parent().get_node("SelectDifficultyMenu").get_node("OptionButton").selected = loaded_data[8]
		get_parent().get_node("SelectDifficultyMenu")._on_option_button_item_selected(loaded_data[8])
		
	slot_num = 4
	
func _on_slot_5_button_up():
	var loaded_data = get_parent().get_parent().load_data(5)
	
	get_parent().get_node("SelectLevelMenu").get_node("LevelSelect").max_value = loaded_data[0] + 1
	get_parent().get_node("SelectLevelMenu").get_node("LevelSelect").set_value_no_signal(loaded_data[0] + 1)
	
	if len(loaded_data) > 8:
		get_parent().get_node("SelectDifficultyMenu").get_node("OptionButton").selected = loaded_data[8]
		get_parent().get_node("SelectDifficultyMenu")._on_option_button_item_selected(loaded_data[8])
		
	slot_num = 5

func _on_select_character_menu_rise_from_depths_animation_player_animation_finished(anim_name):
	var global_data = get_parent().load_data("global")
	var local_slot_data = get_parent().load_data($SelectSlotMenu.slot_num)
	
	if start_game_on_next_animation_finish:
		start_game_on_next_animation_finish = false
		get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play("SelectLevelMenuStartGameAnimation")
		
	if anim_name == "SelectSlotMenuStartGameAnimation" || anim_name == "SelectCharacterMenuStartGameAnimation" || anim_name == "SelectLevelMenuStartGameAnimation":
		get_parent().start_game($SelectSlotMenu.slot_num, local_slot_data[7], global_data[0], null, null, $SelectLevelMenu/LevelSelect.value - 1 if $SelectLevelMenu/LevelSelect.value != get_parent().load_data($SelectSlotMenu.slot_num)[0] + 1 else null, 0, false, false, get_node("SelectDifficultyMenu").get_node("OptionButton").selected)
	if (anim_name == "SelectSlotMenuRiseFromDepthsAnimation" && $SelectSlotMenu.open_character_select_menu):
		$SelectSlotMenu.open_character_select_menu = false
		get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play("SelectCharacterMenuRiseFromDepthsAnimation")

func _on_window_type_selection_item_selected(index):
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_v_sync_mode_selection_item_selected(index):
	if index == 0:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	if index == 1:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if index == 2:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	if index == 3:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)

func _on_option_button_item_selected(index):
	if index == 0:
		get_parent().get_node("SelectSlotMenu").get_node("SelectDifficultyButton").text = "Difficutly: Casual"
	if index == 1:
		get_parent().get_node("SelectSlotMenu").get_node("SelectDifficultyButton").text = "Difficutly: Normal"
	if index == 2:
		get_parent().get_node("SelectSlotMenu").get_node("SelectDifficultyButton").text = "Difficutly: Expert"
	if index == 3:
		get_parent().get_node("SelectSlotMenu").get_node("SelectDifficultyButton").text = "Difficutly: Fremen"

func _on_select_difficulty_button_button_up():
	get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play_backwards("SelectSlotMenuRiseFromDepthsAnimation")
	get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").queue("SelectDifficultyMenuRiseFromDepthsAnimation")

func _on_select_level_button_button_up():
	get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play_backwards("SelectSlotMenuRiseFromDepthsAnimation")
	get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").queue("SelectLevelMenuRiseFromDepthsAnimation")

func _on_select_difficulty_continue_button_up():
	get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play_backwards("SelectDifficultyMenuRiseFromDepthsAnimation")
	get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").queue("SelectSlotMenuRiseFromDepthsAnimation")

func _on_select_level_continue_button_up():
	get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play_backwards("SelectLevelMenuRiseFromDepthsAnimation")
	get_parent().start_game_on_next_animation_finish = true

func _on_special_music_fade_out_timer_timeout():
	get_parent().end_special_music()

func _on_select_level_back_button_up():
	get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").play_backwards("SelectLevelMenuRiseFromDepthsAnimation")
	get_parent().get_node("SelectCharacterMenuRiseFromDepthsAnimationPlayer").queue("SelectSlotMenuRiseFromDepthsAnimation")
