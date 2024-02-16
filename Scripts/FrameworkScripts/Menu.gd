extends Node2D

var character_type = 1
var deactivated = false
var credits_open = false
@export var first = true
@onready var credits_instance = preload("res://Levels/Cutscenes/Credits.tscn")
var hovered_button = "PlayButton"
var selected_other_menu = false
var settings_menu_selected = false

func deactivate():
	hide()
	deactivated = true
	# Deactivate all menu nodes!
	
func activate():
	show()
	deactivated = false 
	# Activate all menu nodes!
	
func _ready():
	if first:
		modulate.a = 0.00001
	
	if name == "SettingsMenu":
		var global_data = get_parent().get_parent().load_data("global")
		$MusicSlider.value = global_data[1]
		$SFXSlider.value = global_data[2]
		$CheckButton.button_pressed = global_data[0]
		$Difficulty.button_pressed = global_data[3]
		$ShowFPS.button_pressed = global_data[4]
		$ShowPoints.button_pressed = global_data[5]
		$ShowSpeedrunTimer.button_pressed = global_data[6]
		
	if name == "StartGameMenu":
		$LevelSelect.set_value_no_signal(get_parent().get_parent().load_data($SlotSelect.value)[0] + 1)

func _process(_delta):
	if modulate.a < 1:
		modulate.a *= 1.1
	
	if name == "SettingsMenu":
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), $MusicSlider.value if $MusicSlider.value > -40 else -10000)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), $SFXSlider.value if $SFXSlider.value > -40 else -10000)
		get_parent().get_parent().save_game(
			"[" + 
			str($CheckButton.button_pressed) + "," + 
			str($MusicSlider.value) + "," + 
			str($SFXSlider.value) + "," + 
			str($Difficulty.button_pressed) + "," + 
			str($ShowFPS.button_pressed) + "," + 
			str($ShowPoints.button_pressed) + "," + 
			str($ShowSpeedrunTimer.button_pressed) + 
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

	if name == "StartGameMenu":
		$LevelSelect.max_value = get_parent().get_parent().load_data($SlotSelect.value)[0] + 1
	
	if name == "MainMenu":
		$PlayHighlight.visible = false
		$SettingsHighlight.visible = false
		$CreditsHighlight.visible = false
		$QuitHighlight.visible = false
		
		if !selected_other_menu:
			if Input.is_action_just_pressed("ui_down"):
				if hovered_button == "PlayHighlight":
					hovered_button = "SettingsHighlight"
				elif hovered_button == "SettingsHighlight":
					hovered_button = "CreditsHighlight"
				elif hovered_button == "CreditsHighlight":
					hovered_button = "QuitHighlight"
					
			if Input.is_action_just_pressed("ui_up"):
				if hovered_button == "SettingsHighlight":
					hovered_button = "PlayHighlight"
				elif hovered_button == "CreditsHighlight":
					hovered_button = "SettingsHighlight"
				elif hovered_button == "QuitHighlight":
					hovered_button = "CreditsHighlight"
					
			if Input.is_action_just_pressed("ui_accept"):
				if hovered_button == "PlayHighlight":
					_on_play_button_button_up()
				if hovered_button == "SettingsHighlight":
					_on_settings_button_button_up()
				if hovered_button == "CreditsHighlight":
					_on_credits_button_button_up()
				if hovered_button == "QuitHighlight":
					_on_quit_button_button_up()
					
				selected_other_menu = true
			
			get_node(hovered_button).visible = true

func _on_play_button_button_up():
	$SettingsMenu.visible = false
	$StartGameMenu.visible = true
	
func _on_settings_button_button_up():
	$SettingsMenu.visible = true
	$StartGameMenu.visible = false
	selected_other_menu = true

func _on_credits_button_button_up():
	if !credits_open:
		credits_open = true
		call_deferred("add_child", credits_instance.instantiate())

func _on_quit_button_button_up():
	get_tree().quit()

func _on_settings_back_button_button_up():
	visible = false

func _on_start_button_up():
	var global_data = get_parent().get_parent().load_data("global")
	get_parent().get_parent().start_game($SlotSelect.value, character_type, global_data[0], null, null, $LevelSelect.value - 1 if $LevelSelect.value != get_parent().get_parent().load_data($SlotSelect.value)[0] + 1 else null, 0)

func _on_type_1_button_down():
	character_type = 1

func _on_type_2_button_down():
	character_type = 2

func _on_type_3_button_down():
	character_type = 3

func _on_type_4_button_down():
	character_type = 4

func _on_clear_slot_button_up():
	get_parent().get_parent().save_data(0, 0, $SlotSelect, 0, 0, {}, 0)

func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()

func _on_slot_select_value_changed(value):
	$LevelSelect.max_value = get_parent().get_parent().load_data($SlotSelect.value)[0] + 1
	$LevelSelect.set_value_no_signal(get_parent().get_parent().load_data(value)[0] + 1)

func _on_play_button_mouse_entered():
	hovered_button = "PlayHighlight"

func _on_settings_button_mouse_entered():
	hovered_button = "SettingsHighlight"

func _on_credits_button_mouse_entered():
	hovered_button = "CreditsHighlight"

func _on_quit_button_mouse_entered():
	hovered_button = "QuitHighlight"
