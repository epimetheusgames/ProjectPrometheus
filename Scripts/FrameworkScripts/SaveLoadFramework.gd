extends Node2D
# Save load framework should be the root node of the main menu.
# It should have a child named Menu, which has a function called
# deactivate() that will completely hide and deactivate the menu.
# Per vis versa, it should have an activate() funciton.

const preloaded_levels = [
	preload("res://Levels/Playable/Level1.tscn"),
]

const level_node_names = [
	"Level1",
]

func _ready():
	save_data(0, 1)
	start_game(1)

# Save game via its respective slot.
func save_game(content, save_num):
	var file = FileAccess.open("user://save_" + save_num.to_string() + ".json", FileAccess.WRITE)
	file.store_string(content)

# Load game via its respective 
func load_game(load_num):
	var file = FileAccess.open("user://save_" + load_num.to_string() + ".json", FileAccess.READ)
	var content = file.get_as_text()
	return content

# Convert level to json and save in respective slot.
func save_data(level, slot):
	var data = [level]
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
		return data_received[0]
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_data, " at line ", json.get_error_line())
		
func start_game(slot):
	var current_level = load_data(slot)
	var level_loaded = preloaded_levels[current_level].instanciate()
	level_loaded.slot = slot
	get_node("Menu").deactivate()
	add_child(level_loaded)
	
func exit_to_menu(level, slot):
	save_data(level, slot)
	get_node(level_node_names[level]).free()
	get_node("Menu").activate()
