extends Node

var sounds = {}

func _ready():
	# Load all your sounds into a dictionary
	sounds = {
		"camaleon_fail": preload("res://assets/sounds/effects/clients/camaleon-fail.wav"),
		"camaleon_pass": preload("res://assets/sounds/effects/clients/camaleon-pass.wav"),
		"gato_fail": preload("res://assets/sounds/effects/clients/gato-fail.wav"),
		"gato_pass": preload("res://assets/sounds/effects/clients/gato-pass.wav"),
		"mamut_fail": preload("res://assets/sounds/effects/clients/mamut-fail.wav"),
		"mamut_pass": preload("res://assets/sounds/effects/clients/mamut-pass.wav"),
		"xolo_fail": preload("res://assets/sounds/effects/clients/xolo-fail.wav"),
		"xolo_pass": preload("res://assets/sounds/effects/clients/xolo-pass.wav"),
		"scroll_ingredient": preload("res://assets/sounds/effects/scroll-ingredient.wav"),
		"select_ingredient": preload("res://assets/sounds/effects/select-ingredient.wav"),
		"trash_torta": preload("res://assets/sounds/effects/trash-torta.wav")
	}

	# Create an AudioStreamPlayer node to play the SFX
	var audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.name = "Player"

func play(sound_name: String):
	var audio_player = $Player
	if sounds.has(sound_name):
		audio_player.stream = sounds[sound_name]
		audio_player.play()
	else:
		push_warning("Sound not found: %s" % sound_name)
