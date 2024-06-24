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
	"Cutscene",
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
	"Medium 6",
	"Tower 1",
	"Tower 2",
	"Tower 3",
	"Transition 1",
	"Boss Fight",
	"Transition 2",
	"Hard 1",
	"Hard 2",
	"Transition 3",
	"Hard 3",
	"Hard 4",
	"Boss Chase",
	"Transition 4",
	"Boss Battle",
	"The End",
	"Credits",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	""
]

const preloaded_levels = [
	["res://Levels/Cutscenes/RocketLandStartCutscene/Floor1.tscn"],
	["res://Levels/Playable/Medium/1Tutorial/Floor1.tscn"],
	["res://Levels/Playable/Medium/2Tutorial/Floor1.tscn"],
	["res://Levels/Playable/Medium/3Tutorial/Floor1.tscn"],
	["res://Levels/Playable/Medium/4Easy/Floor1.tscn"],
	["res://Levels/Playable/Medium/5Easy/Floor1.tscn"],
	["res://Levels/Playable/Medium/6Easy/Floor1.tscn"],
	["res://Levels/Playable/Medium/7Easy/Floor1.tscn"],
	["res://Levels/Playable/Medium/8BigDrone/Floor1.tscn"],
	["res://Levels/Playable/Medium/9PuzzlePre/Floor1.tscn"],
	["res://Levels/Playable/Medium/10Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/11Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/12Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/15PuzzlePost/Floor1.tscn"],
	["res://Levels/Playable/Medium/13Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/14Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/15Exploration/Floor1.tscn"],
	["res://Levels/Playable/Medium/16Biodome/Floor1.tscn"],
	["res://Levels/Playable/Medium/18LongLevel/Floor1.tscn",],
	["res://Levels/Playable/Medium/20LongLevel/Floor1.tscn",],
	["res://Levels/Playable/Medium/21ConveyorDrop/Floor1.tscn",],
	["res://Levels/Playable/Medium/22ConveyorDrop/Floor1.tscn",],
	["res://Levels/Playable/Medium/23TowerLevel/Floor1.tscn",],
	["res://Levels/Playable/Medium/23TowerLevel/Floor2.tscn",],
	["res://Levels/Playable/Medium/23TowerLevel/Floor3.tscn",],
	["res://Levels/Playable/Medium/26BossFightPre/Floor1.tscn"],
	["res://Levels/Playable/Medium/27BossFight/Floor1.tscn"],
	["res://Levels/Playable/Medium/28BossFightPost/Floor1.tscn"],
	["res://Levels/Playable/Medium/28HardLevel/Floor1.tscn"],
	["res://Levels/Playable/Medium/30SurfaceElevatorPuzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/31EndElevatorRide/Floor1.tscn"],
	["res://Levels/Playable/Medium/32LastLevel/Floor1.tscn"],
	["res://Levels/Playable/Medium/29HardLevel/Floor1.tscn"],
	["res://Levels/Playable/Medium/33MassiveDroneChase/Floor1.tscn"],
	["res://Levels/Cutscenes/34MassiveDroneBattleCutscene/Floor1.tscn"],
	["res://Levels/Playable/Medium/35MassiveDroneBattle/Floor1.tscn"],
	["res://Levels/Playable/Medium/EndScreen/Floor1.tscn"],
	["res://Levels/Cutscenes/Credits/Floor1.tscn"],
	["res://Levels/Playable/Multiplayer/Multiplayer1/Floor1.tscn"],
	["res://Levels/Playable/Multiplayer/Multiplayer2/Floor1.tscn"],
]

const preloaded_hard_levels = [
	["res://Levels/Cutscenes/RocketLandStartCutscene/Floor1.tscn"],
	["res://Levels/Playable/Hard/0Tutorial/Floor1.tscn"],
	["res://Levels/Playable/Hard/1Tutorial/Floor1.tscn"],
	["res://Levels/Playable/Hard/2Tutorial/Floor1.tscn"],
	["res://Levels/Playable/Hard/3Easy/Floor1.tscn"],
	["res://Levels/Playable/Hard/4Easy/Floor1.tscn"],
	["res://Levels/Playable/Hard/6Easy/Floor1.tscn"],
	["res://Levels/Playable/Hard/7Easy/Floor1.tscn"],
	["res://Levels/Playable/Hard/8BigDrone/Floor1.tscn"],
	["res://Levels/Playable/Hard/9PuzzlePre/Floor1.tscn"],
	["res://Levels/Playable/Medium/10Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/11Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/12Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/15PuzzlePost/Floor1.tscn"],
	["res://Levels/Playable/Medium/13Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/14Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/15Exploration/Floor1.tscn"],
	["res://Levels/Playable/Hard/16Biodome/Floor1.tscn"],
	["res://Levels/Playable/Hard/18LongLevel/Floor1.tscn",],
	["res://Levels/Playable/Hard/20LongLevel/Floor1.tscn",],
	["res://Levels/Playable/Hard/21ConveyorDrop/Floor1.tscn",],
	["res://Levels/Playable/Hard/22ConveyorDrop/Floor1.tscn",],
	["res://Levels/Playable/Hard/23TowerLevel/Floor1.tscn",],
	["res://Levels/Playable/Hard/23TowerLevel/Floor2.tscn",],
	["res://Levels/Playable/Hard/23TowerLevel/Floor3.tscn",],
	["res://Levels/Playable/Medium/26BossFightPre/Floor1.tscn"],
	["res://Levels/Playable/Hard/27BossFight/Floor1.tscn"],
	["res://Levels/Playable/Medium/28BossFightPost/Floor1.tscn"],
	["res://Levels/Playable/Hard/28HardLevel/Floor1.tscn"],
	["res://Levels/Playable/Hard/30SurfaceElevatorPuzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/31EndElevatorRide/Floor1.tscn"],
	["res://Levels/Playable/Hard/32LastLevel/Floor1.tscn"],
	["res://Levels/Playable/Hard/29HardLevel/Floor1.tscn"],
	["res://Levels/Playable/Hard/33MassiveDroneChase/Floor1.tscn"],
	["res://Levels/Cutscenes/34MassiveDroneBattleCutscene/Floor1.tscn"],
	["res://Levels/Playable/Hard/35MassiveDroneBattle/Floor1.tscn"],
	["res://Levels/Playable/Hard/EndScreen/Floor1.tscn"],
	["res://Levels/Cutscenes/Credits/Floor1.tscn"],
	["res://Levels/Playable/Multiplayer/Multiplayer1/Floor1.tscn"],
	["res://Levels/Playable/Multiplayer/Multiplayer2/Floor1.tscn"],
]

# Yeah I know
const preloaded_easy_levels = [
	["res://Levels/Cutscenes/RocketLandStartCutscene/Floor1.tscn"],
	["res://Levels/Playable/Medium/1Tutorial/Floor1.tscn"],
	["res://Levels/Playable/Medium/2Tutorial/Floor1.tscn"],
	["res://Levels/Playable/Medium/3Tutorial/Floor1.tscn"],
	["res://Levels/Playable/Medium/4Easy/Floor1.tscn"],
	["res://Levels/Playable/Medium/5Easy/Floor1.tscn"],
	["res://Levels/Playable/Medium/6Easy/Floor1.tscn"],
	["res://Levels/Playable/Medium/7Easy/Floor1.tscn"],
	["res://Levels/Playable/Medium/8BigDrone/Floor1.tscn"],
	["res://Levels/Playable/Medium/9PuzzlePre/Floor1.tscn"],
	["res://Levels/Playable/Medium/10Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/11Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/12Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/15PuzzlePost/Floor1.tscn"],
	["res://Levels/Playable/Medium/13Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/14Puzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/15Exploration/Floor1.tscn"],
	["res://Levels/Playable/Medium/16Biodome/Floor1.tscn"],
	["res://Levels/Playable/Easy/18LongLevel/Floor1.tscn",],
	["res://Levels/Playable/Medium/20LongLevel/Floor1.tscn",],
	["res://Levels/Playable/Medium/21ConveyorDrop/Floor1.tscn",],
	["res://Levels/Playable/Medium/22ConveyorDrop/Floor1.tscn",],
	["res://Levels/Playable/Medium/23TowerLevel/Floor1.tscn",],
	["res://Levels/Playable/Medium/23TowerLevel/Floor2.tscn",],
	["res://Levels/Playable/Medium/23TowerLevel/Floor3.tscn",],
	["res://Levels/Playable/Medium/26BossFightPre/Floor1.tscn"],
	["res://Levels/Playable/Medium/27BossFight/Floor1.tscn"],
	["res://Levels/Playable/Medium/28BossFightPost/Floor1.tscn"],
	["res://Levels/Playable/Medium/28HardLevel/Floor1.tscn"],
	["res://Levels/Playable/Medium/30SurfaceElevatorPuzzle/Floor1.tscn"],
	["res://Levels/Playable/Medium/31EndElevatorRide/Floor1.tscn"],
	["res://Levels/Playable/Medium/32LastLevel/Floor1.tscn"],
	["res://Levels/Playable/Medium/29HardLevel/Floor1.tscn"],
	["res://Levels/Playable/Medium/33MassiveDroneChase/Floor1.tscn"],
	["res://Levels/Cutscenes/34MassiveDroneBattleCutscene/Floor1.tscn"],
	["res://Levels/Playable/Medium/35MassiveDroneBattle/Floor1.tscn"],
	["res://Levels/Playable/Medium/EndScreen/Floor1.tscn"],
	["res://Levels/Cutscenes/Credits/Floor1.tscn"],
	["res://Levels/Playable/Multiplayer/Multiplayer1/Floor1.tscn"],
	["res://Levels/Playable/Multiplayer/Multiplayer2/Floor1.tscn"],
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

# Level, ID, for highlighting levels where you haven't found all the secret areas.
const secret_area_data = [
	[45634, 4],
	[567295, 4],
	[90909, 6],
	[38478, 6],
	[812504, 7],
	[12849, 9],
	[10101054, 11],
	[656456111, 16],
	[45634, 17],
	[42069, 18],
	[333454, 20],
	[69420, 21],
	[91274, 22],
	[111884, 22],
	[404404404, 22],
	[424242424, 23],
	[10106778, 23],
	[76934, 23],
	[999945, 24],
	[27384, 24],
	[909087655, 25],
	[333456743, 25],
	[924447954, 30],
	[93574, 31],
	[9876543, 32],
	[98765, 32],
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
var boss_health = 100
var turret_one_health = 100
var turret_two_health = 100
var current_objective = ""
var achievement_popup_queue = []

# Very important! This should be checked to create an export in demo mode!
@export var demo_mode = false
@export var demo_mode_max_level = 2
@onready var demo_mode_ad_level = preload("res://Levels/Cutscenes/DemoModeFinishLevel/Floor1.tscn")

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
	#DiscordSDK.run_callbacks()
	
	if !playing_intense_music && len(get_parent().get_node("Level").get_children()) > 0 && get_parent().get_node("Level").get_children()[0].intense_music:
		start_intense_music()
		
	if achievement_popup_queue.size() > 0:
		if !$AchievementPopup/AchievementPopupAnimationPlayer.is_playing():
			$AchievementPopup/Container/AchievementPopup/Name.text = achievement_popup_queue[-1]
			$AchievementPopup/AchievementPopupAnimationPlayer.play("Popup")
			achievement_popup_queue.pop_back()
	
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
	
	if $BackgroundMusicPlayer.playing == false && len(get_children()) <= 6:
		var musics_list = music_files if !get_parent().get_node("Level").get_children()[0].intense_music else intense_music_files
		
		var music_index = rng.randi_range(0, len(musics_list) - 1)
		while music_index == last_music_ind && len(musics_list) != 1:
			music_index = rng.randi_range(0, len(musics_list) - 1)
			
		var music_stream = musics_list[music_index]
		$BackgroundMusicPlayer.stream = music_stream
		$BackgroundMusicPlayer.play()
		$BackgroundMusicPlayer.playing = true
		last_music_ind = music_index
	
	if $BackgroundMusicPlayer.playing == true && len(get_children()) > 6:
		$BackgroundMusicPlayer.playing = false
	
	real_bulge += (bulge_amm - real_bulge) * 0.01 * delta * 60
	real_static += (static_amm - real_static) * 0.05 * delta * 60
	
	if len(get_children()) > 6:
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
	var file = "NOT LOADED"
	var config: ConfigFile
	var err: Error
	
	if !str(load_num) == "achievements":
		file = FileAccess.open("user://save_" + str(load_num) + ".json", FileAccess.READ)
	else:
		config = ConfigFile.new()
		err = config.load("user://achievements.cfg")
	
	if not file || err != OK:
		print("Possibly error loading achievements. Error code " + str(err))
		
		if str(load_num) == "global":
			save_game("[false, 0, 0, false, false, false, false, 0, 0]", "global")
			return load_game("global")
		
		# Use ConfigFile to save encrypted data for achievements. 
		if str(load_num) == "achievements":
			var achievements_config := ConfigFile.new()
			
			# Store default achievement values.
			# Achievements taken from https://docs.google.com/spreadsheets/d/15wk3SlIrOhFVZB0BcL3EusQI8U8TWn-LlSPo1d7INYw
			achievements_config.set_value("achievements", "open_game", false)
			achievements_config.set_value("achievements", "5k_points", false)
			achievements_config.set_value("achievements", "10k_points", false)
			achievements_config.set_value("achievements", "200_deaths", false)
			achievements_config.set_value("achievements", "500_deaths", false)
			achievements_config.set_value("achievements", "kill_50_drills", false)
			achievements_config.set_value("achievements", "kill_50_drones", false)
			achievements_config.set_value("achievements", "kill_50_melee", false)
			achievements_config.set_value("achievements", "kill_200_drones", false)
			achievements_config.set_value("achievements", "die_spec_10x", false)
			achievements_config.set_value("achievements", "col_1_artifact", false)
			achievements_config.set_value("achievements", "col_10_artifacts", false)
			achievements_config.set_value("achievements", "kill_boss_1", false)
			achievements_config.set_value("achievements", "kill_boss_final", false)
			achievements_config.set_value("achievements", "escape", false)
			achievements_config.set_value("achievements", "10_achievements", false)
			achievements_config.set_value("achievements", "20_achievements", false)
			achievements_config.set_value("achievements", "all_achievements", false)
			achievements_config.set_value("achievements", "finish_50_min", false)
			achievements_config.set_value("achievements", "finish_35_min", false)
			achievements_config.set_value("achievements", "finish_25_min", false)
			achievements_config.set_value("achievements", "start_hard", false)
			achievements_config.set_value("achievements", "finish_hard", false)
			achievements_config.set_value("achievements", "finish_no_deaths", false)
			achievements_config.set_value("achievements", "finish_20_deaths", false)
			achievements_config.set_value("achievements", "finish_50_deaths", false)
			achievements_config.set_value("achievements", "kill_50_birds", false)
			achievements_config.set_value("achievements", "100_percent", false)
			
			# Tracking things required for achievements.
			achievements_config.set_value("tracking", "total_points", 0)
			achievements_config.set_value("tracking", "total_deaths", 0)
			achievements_config.set_value("tracking", "total_artifacts", 0)
			achievements_config.set_value("tracking", "drill_kills", 0)
			achievements_config.set_value("tracking", "drone_kills", 0)
			achievements_config.set_value("tracking", "melee_kills", 0)
			achievements_config.set_value("tracking", "drill_kills", 0)
			achievements_config.set_value("tracking", "bird_kills", 0)
			achievements_config.set_value("tracking", "achievements_collected", 0)
			
			# Save to achievements file
			achievements_config.save("user://achievements.cfg")
			
			# Return the actual ConfigFile, this is probably what we're trying
			# to get out of the function.
			return achievements_config
		
		save_data(0, 0, load_num, 0, 0, {}, 0, false, character_type, 1)
		file = FileAccess.open("user://save_" + str(load_num) + ".json", FileAccess.READ)
	
	if str(load_num) != "achievements":
		var content = file.get_as_text()
		return content
	else:
		return config

# Convert level to json and save in respective slot.
func save_data(level, floor, slot, points, time, artifact_data, deaths, is_character_type_selected, character_value, difficulty):
	var data = [level, floor, points, time, artifact_data, deaths, is_character_type_selected, character_value, difficulty]
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

func save_achievement(achievement_name):
	var achievements_config = load_game("achievements")
	
	if !achievements_config.get_value("achievements", achievement_name):
		achievements_config.set_value("achievements", achievement_name, true)
		
		var total_achievements = achievements_config.get_value("tracking", "achievements_collected") + 1
		achievements_config.set_value("tracking", "achievements_collected", total_achievements)
		
		if total_achievements == 10:
			achievements_config.set_value("achievements", "10_achievements", true)
		if total_achievements == 20:
			achievements_config.set_value("achievements", "20_achievements", true)
		if total_achievements == 27:
			achievements_config.set_value("achievements", "all_achievements", true)
			
		# UI popup in the corner of the screen.
		achievement_popup_queue.append(achievement_name)
		
	achievements_config.save("user://achievements.cfg")
	
func save_achievement_tracking(tracker_name, value):
	var achievements_config = load_game("achievements")
	achievements_config.set_value("tracking", tracker_name, value)
	achievements_config.save("user://achievements.cfg")
	
func load_achievement_tracking(tracker_name):
	var achievements_config = load_game("achievements")
	return achievements_config.get_value("tracking", tracker_name)

# Start the game with all this info which should be loaded from a save file.
func start_game(slot, player_type, graphics_efficiency, player_spawn_pos = null, player_respawn_ability = null, level = null, floor = null, easy_mode = false, use_level_transition = false, difficulty = 1):
	var level_data = load_data(slot)
	var current_level = level_data[0]
	var level_floor = level_data[1]
	var slot_points = level_data[2]
	var slot_time = level_data[3]
	var slot_deaths = level_data[5]
	
	update_rpc_discord(current_level + 1 if !level else level + 1)
	
	var global_data = load_data("global")
	
	if level != null:
		current_level = level 
		level_floor = floor 
	
	var level_list = preloaded_levels
	
	if difficulty == 2:
		level_list = preloaded_hard_levels
		
		# This is the easy way to implement this achievement.
		save_achievement("start_hard")
		
	if difficulty == 0:
		level_list = preloaded_easy_levels
	
	var level_loaded = load(level_list[current_level][level_floor]).instantiate()
	
	# Perform demo check.
	if demo_mode && current_level > demo_mode_max_level:
		level_loaded = demo_mode_ad_level.instantiate()
		level_loaded.demo_running = true
		level_loaded.demo_max = true
	elif demo_mode:
		level_loaded.demo_running = true
	
	current_level_ind = current_level
	level_loaded.slot = slot
	level_loaded.level = current_level
	level_loaded.floor = level_floor
	level_loaded.points = slot_points
	level_loaded.previous_points = slot_points
	level_loaded.time = slot_time
	level_loaded.deaths = slot_deaths
	level_loaded.difficulty = difficulty
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
func exit_to_menu(level, floor, slot, points, time, is_max_level, deaths, dont_fade, difficulty):
	if is_max_level:
		save_data(level, floor, slot, points, time, load_data(slot)[4], deaths, true, load_data(slot)[7], difficulty)
	var saved_data = load_data(slot)
	save_data(saved_data[0], saved_data[1], slot, points, time, saved_data[4], deaths, true, load_data(slot)[7], difficulty)
	get_parent().get_node("Level").get_children()[0].queue_free()
	var menu_instance = menu.instantiate()
	menu_instance.dont_fade = dont_fade
	menu_instance.first = false
	add_child(menu_instance)

# Background function for switching levels. Exits to menu first, saves data,
# and starts the game again.
func switch_to_level(switch_level, switch_floor, current_level, current_floor, player_type, slot, graphics_efficiency, points, time, deaths, is_max_level = true, respawn_pos = null, respawn_ability = null, level = null, floor = null, easy_mode = false, difficulty = 1):
	exit_to_menu(current_level, current_floor, slot, points, time, is_max_level, deaths, switch_level == 1, difficulty)
	if is_max_level:
		save_data(switch_level, switch_floor, slot, points, time, load_data(slot)[4], deaths, true, load_data(slot)[7], difficulty)
	
	var saved_data = load_data(slot)
	save_data(saved_data[0], saved_data[1], slot, points, time, saved_data[4], deaths, true, saved_data[7], difficulty)
	
	start_game(slot, player_type, graphics_efficiency, respawn_pos, respawn_ability, null if is_max_level else switch_level, null if is_max_level else switch_floor, easy_mode, true, difficulty)

# Saves artifact with uid in slot so you cannot collect it again.
func collect_artifact(slot, uid):
	var data = load_data(slot)
	data[4][uid] = true
	save_data(data[0], data[1], slot, data[2], data[3], data[4], data[5], true, data[7], data[8] if len(data) > 8 else 1)
	
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
	pass
