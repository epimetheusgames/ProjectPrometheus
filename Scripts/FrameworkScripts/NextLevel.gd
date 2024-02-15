extends Area2D

var active = true
var use_parent_add = false
var player_in_area = false
@export var auto_next = false

func _ready():
	area_exited.connect(_on_area_exited)

func _on_area_entered(area):
	if area.name == "PlayerHurtbox" && active:
		player_in_area = true
		
		if auto_next:
			if !use_parent_add:
				add_level()
			else:
				get_parent().add_level
		
func _on_area_exited(area):
	if area.name == "PlayerHurtbox":
		player_in_area = false
		
func _process(delta):
	if player_in_area && Input.is_action_just_pressed("interact"):
		if !use_parent_add:
			add_level()
		else:
			get_parent().add_level
		
func add_level():
	var level = get_parent().level
	var floor = get_parent().floor
	var floors_this_level = get_parent().get_parent().get_parent().get_node("SaveLoadFramework").level_node_names[level]
	var level_next = level
	var floor_next = floor
	var graphics_efficiency = get_parent().graphics_efficiency
	
	if floors_this_level[floor] == floors_this_level[-1]:
		level_next += 1
		floor_next = 0
	else:
		floor_next += 1
	
	if !get_parent().is_multiplayer:
		get_parent().get_parent().get_parent().get_node("SaveLoadFramework").switch_to_level(level_next, floor_next, level, floor, get_parent().get_node("Player").get_node("Player").character_type, get_parent().slot, graphics_efficiency, get_parent().points, get_parent().time, get_parent().deaths, get_parent().is_max_level, null, null, null, null, get_parent().easy_mode)

func restart_level(respawn_pos, respawn_ability):
	var level = get_parent().level
	var floor = get_parent().floor
	var graphics_efficiency = get_parent().graphics_efficiency
	
	if !get_parent().is_multiplayer:
		get_parent().get_parent().get_parent().get_node("SaveLoadFramework").switch_to_level(level, floor, level, floor, get_parent().get_node("Player").get_node("Player").character_type, get_parent().slot, graphics_efficiency, get_parent().points, get_parent().time, get_parent().deaths, get_parent().is_max_level, respawn_pos, respawn_ability, get_parent().easy_mode)
	else:
		var respawning_player = null
		
		if multiplayer.is_server():
			respawning_player = get_parent().server_player
		else:
			respawning_player = get_parent().client_player
			
		if !respawning_player.is_multiplayer_authority():
			return
		
		respawning_player.get_node("Player").position = Vector2.ZERO
		
		if respawning_player.get_node("Camera").get_node("AbilityManager").ability_index != 0:
			respawning_player.get_node("Camera").get_node("AbilityManager").ability_index -= 1
		else:
			respawning_player.get_node("Camera").get_node("AbilityManager").ability_index = 3
		respawning_player.get_node("Camera").get_node("AbilityManager").next_ability()
		
		respawning_player.self_modulate.r = 0
		respawning_player.get_node("Camera").get_node("DarkOverlay").color.a = 0
		respawning_player.get_node("Camera").get_node("AbilityManager").get_node("AbililtySwitchTimer").start()
		respawning_player.get_node("Camera").get_node("CloseAnimator").get_node("BlackBarBottom").scale.y = 0
		respawning_player.get_node("Camera").get_node("CloseAnimator").get_node("BlackBarTop").scale.y = 0
		respawning_player.get_node("Camera").get_node("CloseAnimator").get_node("WhiteLine").scale.x = 700
		respawning_player.get_node("Camera").get_node("CloseAnimator").get_node("WhiteLine").visible = false
		respawning_player.get_node("Camera").get_node("CloseAnimator").get_node("ColorRect").color.a = 0
		respawning_player.get_node("Camera").get_node("CloseAnimator").closing = false
		respawning_player.get_node("Camera").get_node("CloseAnimator").start = false
		respawning_player.get_node("Player").get_node("BulletHurtCooldown").stop()
		respawning_player.get_node("Player").get_node("BulletBadHurtcooldown").stop()
		respawning_player.get_node("Player").get_node("PlayerAnimation").modulate = Color.WHITE
		respawning_player.get_node("Player").dead = false
			
