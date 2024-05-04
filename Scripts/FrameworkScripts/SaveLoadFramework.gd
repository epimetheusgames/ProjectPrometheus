# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegal, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# --------------------------------------- SaveLoadFramework.gd ------------------------------------------|
# Base framework for handling interlevel stability, presesrvation of game state, loading the game and    |
# switching between the level and the main menu.                                                         |
# -------------------------------------------------------------------------------------------------------|

extends Node2D
# Save load framework should be the root node of the main menu.
# It should have a child named Menu, which holds the UI of the
# menu.

const level_display_names = [
	"Tutorial 1",
	"Tutorial 2",
	"Tutorial 3",
	"Easy 1",
	"Easy 2",
	"Easy 3",
	"Easy 4",
	"Easy 5",
	"Puzzle 1",
	"Puzzle 2",
	"Puzzle 3",
	"Puzzle 4",
	"Medium 1",
	"Puzzle 5",
	"Puzzle 6",
	"Medium 2",
	"Biodome",
	"Medium 3",
	"Medium 4",
	"Medium 5",
	"Tower 1",
	"Tower 2",
	"Tower 3",
	"Pre Boss Fight",
	"Boss Fight",
	"Elevator Transition",
	"Hard 1",
	"Hard 2",
	"Hard 3",
	"Elevator Transition",
	"Hard 4",
	"Boss Chase",
	"Transition Cutscene",
	"Boss Battle",
	"The End",
	"Credits",
	"",
	"",
	"",
	"",
	""
]

const preloaded_levels = [
	#[preload("res://Levels/Cutscenes/RocketLandStartCutscene/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/1Tutorial/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/2Tutorial/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/3Tutorial/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/4Easy/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/5Easy/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/6Easy/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/7Easy/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/8BigDrone/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/9PuzzlePre/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/10Puzzle/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/11Puzzle/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/12Puzzle/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/15PuzzlePost/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/13Puzzle/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/14Puzzle/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/15Exploration/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/16Biodome/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/18LongLevel/Floor1.tscn"),],
	[preload("res://Levels/Playable/Medium/21ConveyorDrop/Floor1.tscn"),],
	[preload("res://Levels/Playable/Medium/22ConveyorDrop/Floor1.tscn"),],
	[preload("res://Levels/Playable/Medium/23TowerLevel/Floor1.tscn"),],
	[preload("res://Levels/Playable/Medium/23TowerLevel/Floor2.tscn"),],
	[preload("res://Levels/Playable/Medium/23TowerLevel/Floor3.tscn"),],
	[preload("res://Levels/Playable/Medium/26BossFightPre/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/27BossFight/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/28BossFightPost/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/28HardLevel/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/29HardLevel/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/30SurfaceElevatorPuzzle/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/31EndElevatorRide/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/32LastLevel/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/33MassiveDroneChase/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/34MassiveDroneBattleCutscene/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/35MassiveDroneBattle/Floor1.tscn")],
	[preload("res://Levels/Playable/Medium/EndScreen/Floor1.tscn")],
	[preload("res://Levels/Cutscenes/Credits/Floor1.tscn")],
	[preload("res://Levels/Playable/Multiplayer/Multiplayer1/Floor1.tscn")],
	[preload("res://Levels/Playable/Multiplayer/Multiplayer2/Floor1.tscn")],
]

const level_node_names = [
	["Level1",],
	["Level2",],
	["Level3",],
	["Level4",],
	["Level5",],
	["Level7",],
	["Level8",],
	["Level9",],
	["Level10",],
	["Level11",],
	["Level12",],
	["Level13",],
	["Level14",],
	["Level15",],
	["Level16",],
	["Level17",],
	["Level18",],
	["Level19",],
	["Level20",],
	["Level16",],
	["Level17",],
	["Level18",],
	["Level19",],
	["Level20",],
	["Level21",],
	["Level22",],
	["Level23",],
	["Level24",],
	["Level25",],
	["Level26",],
	["Level27",],
	["Level25",],
	["Level26",],
	["Level27",],
	["Level28",],
	["Level29",],
	["Level30",],
	["Level31",],
	["Level32",],
	["Level33",],
	["Credits",],
]

const music_files = [
	preload("res://Assets/Audio/Music/Oskillate.ogg"),
	preload("res://Assets/Audio/Music/Arpeggiator.ogg"),
	preload("res://Assets/Audio/Music/Winds-of-Exhilation.ogg"),
	preload("res://Assets/Audio/Music/Metallic-Fire.ogg"),
	preload("res://Assets/Audio/Music/AlejandroLevelMusic.wav")
]

const intense_music_files = [
	preload("res://Assets/Audio/Music/Dronium.ogg"),
]

const menu = preload("res://Objects/FrameworkNodes/MainMenu.tscn")
var current_level_name = ""
var current_level_ind = -1
var bulge_amm = 0.0
var real_bulge = 0.0
var static_amm = 0.0
var real_static = 0.0
var player_camera_position = Vector2.ZERO
var last_music_ind = -1
var starting = true
var force_time_scale = -1.0
var playing_special_music = false
var playing_intense_music = false
var has_keycard = false
var boss_fifty_percent = false
var boss_music_ind = -1
var current_objective = ""

@onready var loaded_carret = preload("res://Assets/Images/Objects/Misc/Carret.png")

func _ready():
	# Load discord rpc
	update_rpc_discord(-1, true)
	
	# Load mouse cursor.
	Input.set_custom_mouse_cursor(loaded_carret, Input.CURSOR_IBEAM)
	
	# Set controller icons process mode to allways so they can update in pause menu ... 
	# this cannot be set in the editor.
	get_parent().get_parent().get_node("ControllerIcons").process_mode = 3
	
	# Set window type to specified window type.
	var global_save_data = load_data("global")
	var window_type = global_save_data[7]
	var vsync_type = global_save_data[8]
	
	# Fullscreen/windowed
	if window_type == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if window_type == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	# VSync type
	if vsync_type == 0:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	if vsync_type == 1:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if vsync_type == 2:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	if vsync_type == 3:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)

func _process(delta):
	# Update DiscordSDK
	DiscordSDK.run_callbacks()
	
	if !playing_intense_music && len(get_parent().get_node("Level").get_children()) > 0 && get_parent().get_node("Level").get_children()[0].intense_music:
		start_intense_music()
	
	if starting && !$EpimetheusFadin.finished:
		$MainMenu.modulate.a = 0
	elif starting:
		$MainMenu.modulate.a += 0.1
		$EpimetheusFadin.modulate.a -= 0.1
		
		if $EpimetheusFadin.modulate.a <= 0:
			$EpimetheusFadin.queue_free()
			starting = false
	
	# Force time scale for TAS or something
	if force_time_scale > 0:
		Engine.time_scale = force_time_scale
		
	var rng = RandomNumberGenerator.new()
	
	# Time slow down for debugging lower fps issues
	#if Input.is_action_just_pressed("ui_up"):
	#	force_time_scale += 0.1
	#if Input.is_action_just_pressed("ui_down"):
	#	force_time_scale -= 0.1
	
	# Induce artificial lag
	#OS.delay_msec(rng.randi_range(20, 200))
	
	if $BackgroundMusicPlayer.playing == false && len(get_children()) <= 5:
		var musics_list = music_files if !get_parent().get_node("Level").get_children()[0].intense_music else intense_music_files
		
		var music_index = rng.randi_range(0, len(musics_list) - 1)
		while music_index == last_music_ind && len(musics_list) != 1:
			music_index = rng.randi_range(0, len(musics_list) - 1)
			
		var music_stream = musics_list[music_index]
		$BackgroundMusicPlayer.stream = music_stream
		$BackgroundMusicPlayer.play()
		$BackgroundMusicPlayer.playing = true
		last_music_ind = music_index
	
	if $BackgroundMusicPlayer.playing == true && len(get_children()) > 5:
		$BackgroundMusicPlayer.playing = false
	
	real_bulge += (bulge_amm - real_bulge) * 0.01 * delta * 60
	real_static += (static_amm - real_static) * 0.05 * delta * 60
	
	if len(get_children()) > 5:
		get_parent().get_node("CanvasLayer/ColorRect").material.set_shader_parameter("distortion_amm", 0.0)
		get_parent().get_node("CanvasLayer/ColorRect").material.set_shader_parameter("static_scale", 0.0)
	else:
		get_parent().get_node("CanvasLayer/ColorRect").material.set_shader_parameter("distortion_amm", real_bulge)
		get_parent().get_node("CanvasLayer/ColorRect").material.set_shader_parameter("static_scale", real_static)
	
	if len(get_parent().get_node("Level").get_children()) > 1:
		get_parent().get_node("Level").get_children()[-1].queue_free()

# Save game via its respective slot.
func save_game(content, save_num):
	var file = FileAccess.open("user://save_" + str(save_num) + ".json", FileAccess.WRITE)
	file.store_string(content)

# Load game via its respective 
func load_game(load_num, character_type = 1):
	var file = FileAccess.open("user://save_" + str(load_num) + ".json", FileAccess.READ)
	
	if not file:
		if str(load_num) == "global":
			save_game("[false, 0, 0, false, false, false, false]", "global")
			return load_game("global")
		
		save_data(0, 0, load_num, 0, 0, {}, 0, false, character_type)
		file = FileAccess.open("user://save_" + str(load_num) + ".json", FileAccess.READ)
	
	var content = file.get_as_text()
	return content

# Convert level to json and save in respective slot.
func save_data(level, floor, slot, points, time, artifact_data, deaths, is_character_type_selected, character_value):
	var data = [level, floor, points, time, artifact_data, deaths, is_character_type_selected, character_value]
	var json_data = JSON.stringify(data)
	save_game(json_data, slot)
	
# Convert json to output level from respective slot.
func load_data(slot):
	var json_data = load_game(slot)
	var json = JSON.new()
	var error = json.parse(json_data)
	
	# Error code grabbed from https://docs.godotengine.org/en/stable/classes/class_json.html
	# I edited it a bit.
	if error == OK:
		var data_received = json.data
		return data_received
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_data, " at line ", json.get_error_line())
		print("Detected issue with save data in save_" + str(slot) + "!")
		
# Start the game with all this info which should be loaded from a save file.
func start_game(slot, player_type, graphics_efficiency, player_spawn_pos = null, player_respawn_ability = null, level = null, floor = null, easy_mode = false, use_level_transition = false):
	var level_data = load_data(slot)
	var current_level = level_data[0]
	var level_floor = level_data[1]
	var slot_points = level_data[2]
	var slot_time = level_data[3]
	var slot_deaths = level_data[5]
	
	update_rpc_discord(current_level + 1 if !level else level + 1)
	
	if !$SpecialAudioPlayer.playing:
		end_special_music()
	
	var global_data = load_data("global")
	
	if level != null:
		current_level = level 
		level_floor = floor 
	
	var level_loaded = preloaded_levels[current_level][level_floor].instantiate()
	current_level_ind = current_level
	level_loaded.slot = slot
	level_loaded.level = current_level
	level_loaded.floor = level_floor
	level_loaded.points = slot_points
	level_loaded.time = slot_time
	level_loaded.deaths = slot_deaths
	level_loaded.graphics_efficiency = graphics_efficiency
	level_loaded.show_fps = global_data[4]
	level_loaded.show_points = global_data[5]
	level_loaded.show_timer = global_data[6]
	
	#if !use_level_transition:
	#	level_loaded.get_node("Player").get_node("Camera").get_node("LevelTransitionAnimationPlayer").play("RESET")
	
	if !level_loaded.is_multiplayer:
		level_loaded.get_node("Player").get_node("Player").character_type = player_type
		level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("AbililtySwitchTimer").set_wait_time(20 if !easy_mode else 40)
	
	level_loaded.easy_mode = easy_mode
	
	if level != null:
		level_loaded.is_max_level = false
	
	if player_spawn_pos && !level_loaded.is_multiplayer:
		level_loaded.get_node("Player").get_node("Player").position = player_spawn_pos
		level_loaded.get_node("Player").get_node("Player").current_ability = player_respawn_ability
		level_loaded.get_node("Player").get_node("Camera").position = player_spawn_pos
		level_loaded.get_node("Player").get_node("CameraCollider").position = player_spawn_pos
		
		if player_respawn_ability == "Weapon":
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").ability_index = 0
		if player_respawn_ability == "RocketBoost":
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").ability_index = 1
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("TickerMask").get_node("Item").rotation = deg_to_rad(90)
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("TickerMask").get_node("Ticker").rotation = deg_to_rad(90)
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").ideal_rotation = deg_to_rad(90)
		if player_respawn_ability == "ArmGun":
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").ability_index = 2
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("TickerMask").get_node("Item").rotation = deg_to_rad(180)
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("TickerMask").get_node("Ticker").rotation = deg_to_rad(180)
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").ideal_rotation = deg_to_rad(180)
		if player_respawn_ability == "Grapple":
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").ability_index = 3
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("TickerMask").get_node("Item").rotation = deg_to_rad(270)
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("TickerMask").get_node("Ticker").rotation = deg_to_rad(270)
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").ideal_rotation = deg_to_rad(180)
			
		level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager")._on_fadin_half_wait_timer_timeout()
	
	get_node("MainMenu").queue_free()
	get_parent().get_node("Level").call_deferred("add_child", level_loaded)
	
# Exit to menu while saving the game.
func exit_to_menu(level, floor, slot, points, time, is_max_level, deaths):
	if is_max_level:
		save_data(level, floor, slot, points, time, load_data(slot)[4], deaths, true, load_data(slot)[7])
	var saved_data = load_data(slot)
	save_data(saved_data[0], saved_data[1], slot, points, time, saved_data[4], deaths, true, load_data(slot)[7])
	get_parent().get_node("Level").get_children()[0].queue_free()
	var menu_instance = menu.instantiate()
	menu_instance.first = false
	add_child(menu_instance)

# Background function for switching levels. Exits to menu first, saves data,
# and starts the game again.
func switch_to_level(switch_level, switch_floor, current_level, current_floor, player_type, slot, graphics_efficiency, points, time, deaths, is_max_level = true, respawn_pos = null, respawn_ability = null, level = null, floor = null, easy_mode = false):
	exit_to_menu(current_level, current_floor, slot, points, time, is_max_level, deaths)
	if is_max_level:
		save_data(switch_level, switch_floor, slot, points, time, load_data(slot)[4], deaths, true, load_data(slot)[7])
	
	var saved_data = load_data(slot)
	save_data(saved_data[0], saved_data[1], slot, points, time, saved_data[4], deaths, true, load_data(slot)[7])
	
	start_game(slot, player_type, graphics_efficiency, respawn_pos, respawn_ability, null if is_max_level else switch_level, null if is_max_level else switch_floor, easy_mode, true)

# Saves artifact with uid in slot so you cannot collect it again.
func collect_artifact(slot, uid):
	var data = load_data(slot)
	data[4][uid] = true
	save_data(data[0], data[1], slot, data[2], data[3], data[4], data[5], true, data[7])
	
# Special music like boss of elevator.
func start_special_music():
	if !playing_special_music:
		playing_special_music = true
		$AudioFader.play("FadeoutLevelMusic")
	
func end_special_music():
	if playing_special_music:
		playing_special_music = false
		$AudioFader.play("FadeinLevelMusic")
		
func start_intense_music():
	$BackgroundMusicPlayer.stop()
	playing_intense_music = true

func update_rpc_discord(level, main_menu = false):
	DiscordSDK.app_id = 1217656093074002020 # Application ID

	if main_menu:
		DiscordSDK.state = "In Main Menu"
	else:
		DiscordSDK.state = "Playing level " + str(level) + "."

	DiscordSDK.large_image = "prometheuslogoglowingnotext2" # Image key from "Art Assets"

	DiscordSDK.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"
	# DiscordSDK.end_timestamp = int(Time.get_unix_time_from_system()) + 3600 # +1 hour in unix time / "01:00:00 remaining"

	DiscordSDK.refresh() # Always refresh after changing the values!
