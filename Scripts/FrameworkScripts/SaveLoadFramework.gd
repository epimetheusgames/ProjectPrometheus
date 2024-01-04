
extends Node2D
# Save load framework should be the root node of the main menu.
# It should have a child named Menu, which holds the UI of the
# menu.

const preloaded_levels = [
	[
		preload("res://Levels/Playable/Level1/Floor1.tscn"),
	],
	[
		preload("res://Levels/Playable/Level2/Floor1.tscn"),
	],
	[
		preload("res://Levels/Playable/Level3/Floor1.tscn"),
	],
	[
		preload("res://Levels/Playable/Level4/Floor1.tscn"),
	],
	[
		preload("res://Levels/Playable/Level5/Floor1.tscn"),
	],
	[
		preload("res://Levels/Playable/Level6/Floor1.tscn"),
	],
	[
		preload("res://Levels/Playable/Level7/Floor1.tscn"),
	],
]

const level_node_names = [
	["Level1",],
	["Level2",],
	["Level3",],
	["Level4",],
	["Level5",],
	["Level6",],
	["Level7",],
]

const menu = preload("res://Objects/FrameworkNodes/Menu.tscn")
var current_level_name = ""
var bulge_amm = 0.0
var real_bulge = 0.0
var static_amm = 0.0
var real_static = 0.0

func _process(delta):
	real_bulge += (bulge_amm - real_bulge) * 0.01 * delta * 60
	real_static += (static_amm - real_static) * 0.05 * delta * 60
	
	if len(get_children()) > 1:
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
			save_game("[false, 0, 0]", "global")
			return load_game("global")
		
		save_data(0, 0, load_num)
		file = FileAccess.open("user://save_" + str(load_num) + ".json", FileAccess.READ)
	
	var content = file.get_as_text()
	return content

# Convert level to json and save in respective slot.
func save_data(level, floor, slot):
	var data = [level, floor]
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
		
func start_game(slot, player_type, graphics_efficiency, player_spawn_pos = null, player_respawn_ability = null, level = null, floor = null):
	var level_data = load_data(slot)
	var current_level = level_data[0]
	var level_floor = level_data[1]
	
	if level != null:
		current_level = level 
		level_floor = floor 
	
	var level_loaded = preloaded_levels[current_level][level_floor].instantiate()
	level_loaded.slot = slot
	level_loaded.level = current_level
	level_loaded.floor = level_floor
	level_loaded.graphics_efficiency = graphics_efficiency
	level_loaded.get_node("Player").get_node("Player").character_type = player_type
	
	if level != null:
		level_loaded.is_max_level = false
	
	if player_spawn_pos:
		level_loaded.get_node("Player").get_node("Player").position = player_spawn_pos
		level_loaded.get_node("Player").get_node("Player").current_ability = player_respawn_ability
		level_loaded.get_node("Player").get_node("Camera").position = player_spawn_pos
		level_loaded.get_node("Player").get_node("Camera").get_node("CameraCollider").position = player_spawn_pos
		
		if player_respawn_ability == "Weapon":
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").ability_index = 0
		if player_respawn_ability == "RocketBoost":
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").ability_index = 1
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("TickerMask").get_node("Item").rotation = deg_to_rad(90)
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("TickerMask").get_node("Ticker").rotation = deg_to_rad(90)
		if player_respawn_ability == "ArmGun":
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").ability_index = 2
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("TickerMask").get_node("Item").rotation = deg_to_rad(180)
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("TickerMask").get_node("Ticker").rotation = deg_to_rad(180)
		if player_respawn_ability == "Grapple":
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").ability_index = 3
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("TickerMask").get_node("Item").rotation = deg_to_rad(270)
			level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager").get_node("TickerMask").get_node("Ticker").rotation = deg_to_rad(270)
			
		level_loaded.get_node("Player").get_node("Camera").get_node("AbilityManager")._on_fadin_half_wait_timer_timeout()
	
	get_node("Menu").queue_free()
	get_parent().get_node("Level").call_deferred("add_child", level_loaded)
	
func exit_to_menu(level, floor, slot, is_max_level):
	if is_max_level:
		save_data(level, floor, slot)
	get_parent().get_node("Level").get_children()[0].queue_free()
	add_child(menu.instantiate())

func switch_to_level(switch_level, switch_floor, current_level, current_floor, player_type, slot, graphics_efficiency, is_max_level = true, respawn_pos = null, respawn_ability = null, level = null, floor = null):
	exit_to_menu(current_level, current_floor, slot, is_max_level)
	save_data(switch_level, switch_floor, slot)
	start_game(slot, player_type, graphics_efficiency, respawn_pos, respawn_ability, null if is_max_level else switch_level, null if is_max_level else switch_floor)
