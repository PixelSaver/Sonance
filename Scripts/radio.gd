extends MeshInstance3D
class_name Radio

@export var knob1 : RigidBody3D
@export var knob2 : RigidBody3D
var knob_hovered : RigidBody3D
var clicked = false

func _ready():
	knob1.connect("mouse_entered", _on_knob_1)
	knob2.connect("mouse_entered", _on_knob_2)
	knob1.connect("mouse_exited", _on_knob_exit)
	knob2.connect("mouse_exited", _on_knob_exit)
	
func _on_knob_1():
	knob_hovered = knob1
func _on_knob_2():
	knob_hovered = knob2
func _on_knob_exit():
	knob_hovered = null
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("left_click"):
		clicked = true
		print_debug(clicked)
	else: 
		clicked = false
		print_debug(clicked)
	
