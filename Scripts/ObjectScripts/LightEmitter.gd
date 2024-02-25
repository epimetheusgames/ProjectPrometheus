extends Sprite2D


func _ready():
	if get_parent().graphics_efficiency:
		$PointLight2D.shadow_filter = 0
