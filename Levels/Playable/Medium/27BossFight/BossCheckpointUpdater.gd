extends Area2D


var entered_yet = false
@export var set_boss_health = 50


func _ready():
	if get_tree().get_root().get_node("Root").get_node("SaveLoadFramework").boss_fifty_percent:
		get_parent().get_node("Boss").health = 49
		get_parent().get_node("Player").get_node("Camera").get_node("BossBar").value = 49

func _on_area_entered(area):
	if area.name == "PlayerHurtbox" && !entered_yet:
		get_parent().get_node("Boss").position = get_parent().get_node("Boss").position + get_parent().get_node("Boss").get_node("FiftyPercentPos").position
		get_parent().get_node("Boss").health = 50
		get_parent().get_node("Player").get_node("Camera").get_node("BossBar").value = 50

func _on_dont_setup_timer_timeout():
	entered_yet = true
