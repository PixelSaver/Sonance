extends Node3D

@export var anim_player : AnimationPlayer

func _ready() -> void:
	anim_player.play("camera_start", -1, 0.)
	main_to_radio()

func main_to_radio():
	if Global.state != Global.States.MENU: return
	Global.state = Global.States.RADIO
	anim_player.play("camera_start")
