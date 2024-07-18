extends TextureRect
class_name ControllerTextureRect

@export var path : String = ""

@export_enum("Both", "Keyboard/Mouse", "Controller") var show_only : int = 0:
	set(_show_only):
		show_only = _show_only
		_on_input_type_changed(ControllerIcons._last_input_type)

@export_enum("None", "Keyboard/Mouse", "Controller") var force_type : int = 0:
	set(_force_type):
		force_type = _force_type
		_on_input_type_changed(ControllerIcons._last_input_type)

@export var max_width : int = 40:
	set(_max_width):
		max_width = _max_width
		if is_inside_tree():
			if max_width < 0:
				expand_mode = TextureRect.EXPAND_KEEP_SIZE
			else:
				expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				custom_minimum_size.x = max_width
				if texture:
					custom_minimum_size.y = texture.get_height() * max_width / texture.get_width()
				else:
					custom_minimum_size.y = custom_minimum_size.x

func _ready():
	ControllerIcons.input_type_changed.connect(_on_input_type_changed)
	self.path = path
	self.max_width = max_width

func _process(delta):
	if len(Input.get_connected_joypads()) > 0 && Input.get_joy_name(0) != "vJoy Device":
		force_type = 2
		texture = ControllerIcons.parse_path(path, 1)
	else:
		force_type = 1
		texture = ControllerIcons.parse_path(path, 0)

func _on_input_type_changed(input_type):
	pass

func get_tts_string() -> String:
	if force_type:
		return ControllerIcons.parse_path_to_tts(path, force_type - 1)
	else:
		return ControllerIcons.parse_path_to_tts(path)
