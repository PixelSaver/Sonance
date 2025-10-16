extends Node3D
class_name MenuButtons

@export var play_but : RadioMenuButton
@export var settings_but : RadioMenuButton
@export var quit_but : RadioMenuButton
var button_hovered = null

func _ready() -> void:
	play_but.connect("pressed", _on_play_pressed)
	settings_but.connect("pressed", _on_settings_pressed)
	quit_but.connect("pressed", _on_quit_pressed)
	
func _on_play_pressed():
	var world = Global.world_root
	if not world: 
		push_error("world is null, %s" % world)
		return
	world.main_to_radio()
func _on_settings_pressed():
	pass
func _on_quit_pressed():
	pass
