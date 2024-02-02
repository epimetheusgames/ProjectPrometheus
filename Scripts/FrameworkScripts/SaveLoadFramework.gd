
extends Node2D
# Save load framework should be the root node of the main menu.
# It should have a child named Menu, which holds the UI of the
# menu.

const preloaded_levels = [
	[preload("res://Levels/Playable/1TutorialA/Floor1.tscn")],
	[preload("res://Levels/Playable/1TutorialB/Floor1.tscn")],
	[preload("res://Levels/Playable/1TutorialC/Floor1.tscn")],
	[preload("res://Levels/Playable/2EasyA/Floor1.tscn")],
	[preload("res://Levels/Playable/2EasyB/Floor1.tscn")],
	[preload("res://Levels/Playable/2EasyC/Floor1.tscn")],
	[preload("res://Levels/Playable/2EasyD/Floor1.tscn")],
	[preload("res://Levels/Playable/3BigDrone/Floor1.tscn")],
	[preload("res://Levels/Playable/4PuzzlePre/Floor1.tscn")],
	[preload("res://Levels/Playable/4PuzzleA/Floor1.tscn")],
	[preload("res://Levels/Playable/4PuzzleB/Floor1.tscn")],
	[preload("res://Levels/Playable/4PuzzleC/Floor1.tscn")],
	[preload("res://Levels/Playable/4PuzzleD/Floor1.tscn")],
	[preload("res://Levels/Playable/4PuzzleE/Floor1.tscn")],
	[preload("res://Levels/Playable/4PuzzlePost/Floor1.tscn")],
	[preload("res://Levels/Playable/5ConveyorDropA/Floor1.tscn"),],
	[preload("res://Levels/Playable/5LongLevelA/Floor1.tscn"),],
	[preload("res://Levels/Playable/5LongLevelB/Floor1.tscn"),],
	[preload("res://Levels/Playable/5ConveyorDropB/Floor1.tscn"),],
	[preload("res://Levels/Playable/6TowerLevelPartA/Floor1.tscn"),],
	[preload("res://Levels/Playable/6TowerLevelPartB/Floor1.tscn"),],
	[preload("res://Levels/Playable/6TowerLevelPartC/Floor1.tscn"),],
	[preload("res://Levels/Playable/7BossFightPre/Floor1.tscn")],
	[preload("res://Levels/Playable/7BossFight/Floor1.tscn")],
	[preload("res://Levels/Playable/8HardLeveA/Floor1.tscn")],
	[preload("res://Levels/Playable/8HardLevelB/Floor1.tscn")],
	[preload("res://Levels/Playable/8SurfaceElevatorPuzzle/Floor1.tscn")],
	[preload("res://Levels/Playable/8EndElevatorRide/Floor1.tscn")],
	[preload("res://Levels/Playable/9LastLevel/Floor1.tscn")],
	[preload("res://Levels/Playable/10MassiveDroneChase/Floor1.tscn")],
	[preload("res://Levels/Playable/EndScreen/Floor1.tscn")],
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
	["Level10",],
	["Level10",],
	["Level10",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
	["Level11",],
]

const music_files = [
	preload("res://Assets/Audio/Music/Oskillate.ogg"),
	preload("res://Assets/Audio/Music/Arpeggiator.ogg"),
	preload("res://Assets/Audio/Music/Winds-of-Exhilation.ogg"),
	preload("res://Assets/Audio/Music/Metallic-Fire.ogg"),
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
@export var force_time_scale = -1.0

func _process(delta):
	
	if starting && !$EpimetheusFadin.finished:
		$MainMenu.modulate.a = 0
	elif starting:
		$MainMenu.modulate.a += 0.1
		$EpimetheusFadin.modulate.a -= 0.1
		
		if $EpimetheusFadin.modulate.a <= 0:
			$EpimetheusFadin.queue_free()
			starting = false
	
	if force_time_scale > 0:
		Engine.time_scale = force_time_scale
	
	# Time slow down for debugging lower fps issues
	#if Input.is_action_just_pressed("ui_up"):
	#	force_time_scale += 0.1
	#if Input.is_action_just_pressed("ui_down"):
	#	force_time_scale -= 0.1
	
	if $BackgroundMusicPlayer.playing == false && len(get_children()) <= 3:
		var rng = RandomNumberGenerator.new()
		var music_index = rng.randi_range(0, len(music_files) - 1)
		while music_index == last_music_ind:
			music_index = rng.randi_range(0, len(music_files) - 1)
			
		var music_stream = music_files[music_index]
		$BackgroundMusicPlayer.stream = music_stream
		$BackgroundMusicPlayer.play()
		$BackgroundMusicPlayer.playing = true
		last_music_ind = music_index
	
	if $BackgroundMusicPlayer.playing == true && len(get_children()) > 3:
		$BackgroundMusicPlayer.playing = false
	
	real_bulge += (bulge_amm - real_bulge) * 0.01 * delta * 60
	real_static += (static_amm - real_static) * 0.05 * delta * 60
	
	if len(get_children()) > 3:
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
func load_game(load_num):
	var file = FileAccess.open("user://save_" + str(load_num) + ".json", FileAccess.READ)
	
	if not file:
		if str(load_num) == "global":
			save_game("[false, 0, 0, false]", "global")
			return load_game("global")
		
		save_data(0, 0, load_num, 0, 0, {})
		file = FileAccess.open("user://save_" + str(load_num) + ".json", FileAccess.READ)
	
	var content = file.get_as_text()
	return content

# Convert level to json and save in respective slot.
func save_data(level, floor, slot, points, time, artifact_data):
	var data = [level, floor, points, time, artifact_data]
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
		
func start_game(slot, player_type, graphics_efficiency, player_spawn_pos = null, player_respawn_ability = null, level = null, floor = null, easy_mode = false):
	var level_data = load_data(slot)
	var current_level = level_data[0]
	var level_floor = level_data[1]
	var slot_points = level_data[2]
	var slot_time = level_data[3]
	
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
	level_loaded.graphics_efficiency = graphics_efficiency
	level_loaded.get_node("Player").get_node("Player").character_type = player_type
	level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("AbililtySwitchTimer").set_wait_time(20 if !easy_mode else 40)
	level_loaded.easy_mode = easy_mode
	
	if level != null:
		level_loaded.is_max_level = false
	
	if level != null:
		level_loaded.is_max_level = false
	
	if player_spawn_pos:
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
	
func exit_to_menu(level, floor, slot, points, time, is_max_level):
	if is_max_level:
		save_data(level, floor, slot, points, time, load_data(slot)[4])
	get_parent().get_node("Level").get_children()[0].queue_free()
	var menu_instance = menu.instantiate()
	menu_instance.first = false
	add_child(menu_instance)

func switch_to_level(switch_level, switch_floor, current_level, current_floor, player_type, slot, graphics_efficiency, points, time, is_max_level = true, respawn_pos = null, respawn_ability = null, level = null, floor = null, easy_mode = false):
	exit_to_menu(current_level, current_floor, slot, points, time, is_max_level)
	if is_max_level:
		save_data(switch_level, switch_floor, slot, points, time, load_data(slot)[4])
	start_game(slot, player_type, graphics_efficiency, respawn_pos, respawn_ability, null if is_max_level else switch_level, null if is_max_level else switch_floor, easy_mode)

func collect_artifact(slot, uid):
	var data = load_data(slot)
	data[4][uid] = true
	save_data(data[0], data[1], slot, data[2], data[3], data[4])
	
