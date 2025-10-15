extends MeshInstance3D
class_name Radio

@export var knob1 : RigidBody3D
@export var knob2 : RigidBody3D
@export var sensitivity : float = 1.
var tuning : float = 0.
var volume : float = 1.
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
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action("left_click"):
			clicked = event.pressed
			if clicked:
				print("Mouse down")
			else:
				print("Mouse up")

	elif event is InputEventMouseMotion:
		if clicked and knob_hovered:
			tuning += -event.relative.y * sensitivity
			tuning = clamp(tuning, 0.0, 100.0) 
			update_knob_turn()
	


func update_knob_turn():
	match knob_hovered:
		null:
			return
		knob1:
			print("Knob value:", tuning)
			knob1.rotation.z = tuning
		knob2:
			pass
	
	
