extends Control


@onready var slot_highlights_list = [
	$SlotHighlights/Line2D,
	$SlotHighlights/Line2D2,
	$SlotHighlights/Line2D3,
	$SlotHighlights/Line2D4,
	$SlotHighlights/Line2D5,
	$SlotHighlights/Line2D6,
]

func make_highlights_invisible():
	return
	for highlight in slot_highlights_list:
		highlight.visible = false

func _on_texture_button_button_up():
	return
	make_highlights_invisible()
	$Line2D.visible = true

func _on_texture_button_2_button_up():
	return
	make_highlights_invisible()
	$Line2D2.visible = true

func _on_texture_button_3_button_up():
	return
	make_highlights_invisible()
	$Line2D3.visible = true

func _on_texture_button_4_button_up():
	return
	make_highlights_invisible()
	$Line2D4.visible = true

func _on_texture_button_5_button_up():
	return
	make_highlights_invisible()
	$Line2D5.visible = true

func _on_exture_button_6_button_up():
	return
	make_highlights_invisible()
	$Line2D6.visible = true
