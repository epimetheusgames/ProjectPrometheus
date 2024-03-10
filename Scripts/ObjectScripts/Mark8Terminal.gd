# -------------------------------------------------------------------------------------------------------|
# Copyright (C) 2024 Carson Bates, Liam Siegel, Elouan Grimm, Alejandro Belgique, and Ranier Szatlocky.  |
# All rights reserved.                                                                                   |
#                                                                                                        |
# Email us at <epimtheusgamesogpc@gmail.com>                                                             |
# -------------------------------------------------------------------------------------------------------|

extends Node2D


var spectrum

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(3, 0) # Three is the Voicelines bus index and 0 is the SpectrumAnalyzer effect


func _process(delta):
	var volume = spectrum.get_magnitude_for_frequency_range(0, 10000).length()
	$Mark8Eyes.self_modulate = Color(1 + volume * 3, 1 + volume * 2, 1 + volume * 2) * 2
