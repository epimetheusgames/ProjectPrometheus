# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|

extends Node2D


var spectrum
@export var bus = 3
@export var offset = 0

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(bus, 0) # Three is the Voicelines bus index and 0 is the SpectrumAnalyzer effect


func _process(delta):
	var volume = spectrum.get_magnitude_for_frequency_range(0, 10000).length()
	$Mark8Eyes.self_modulate = Color(1 + volume * 3, 1 + volume * 2, 1 + volume * 2) * 2 - Color(offset, offset, offset, 1)
