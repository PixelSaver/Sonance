extends Node3D
class_name MenuButtons

@export var button1 : RigidBody3D
@export var button2 : RigidBody3D
@export var button3 : RigidBody3D
var button_hovered = null

func _ready() -> void:
	return
	button1.connect("mouse_entered", _on_button1_hov)
	button2.connect("mouse_entered", _on_button2_hov)
	button3.connect("mouse_entered", _on_button3_hov)

func _on_button1_hov():
	button_hovered = button1
func _on_button2_hov():
	button_hovered = button2
func _on_button3_hov():
	button_hovered = button3
