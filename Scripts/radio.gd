extends MeshInstance3D
class_name Radio

@export var knob1 : RigidBody3D
@export var knob2 : RigidBody3D
@export var sensitivity : float = 0.1
@export var tuning_fork : RigidBody3D
@export var outline_component : OutlineComponent
var tuning : float = 0.
var volume : float = 1.
var knob_hovered : RigidBody3D
var clicked = false
var dragging = false

func _ready():
	knob1.connect("mouse_entered", _on_knob_1)
	knob2.connect("mouse_entered", _on_knob_2)
	knob1.connect("mouse_exited", _on_knob_exit)
	knob2.connect("mouse_exited", _on_knob_exit)
	
func _on_knob_1():
	if dragging: return
	outline_component.outline_parent(true,\
			knob1.get_node("KnobModel"))
	knob_hovered = knob1
func _on_knob_2():
	if dragging: return
	outline_component.outline_parent(true,\
			knob2.get_node("KnobModel"))
	knob_hovered = knob2
func _on_knob_exit():
	outline_component.outline_parent(false,\
			knob1.get_node("KnobModel"))
	outline_component.outline_parent(false,\
			knob2.get_node("KnobModel"))
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action("left_click"):
			clicked = event.pressed
			if clicked:
				pass
			else:
				dragging = false

	if event is InputEventMouseMotion:
		if clicked and knob_hovered:
			dragging = true
		update_knob_turn(event as InputEventMouseMotion)
	


func update_knob_turn(event:InputEventMouseMotion):
	if not dragging: return
	match knob_hovered:
		null:
			return
		knob2:
			update_tuning(event.relative)
		knob1:
			volume += (-event.relative.y + event.relative.x) * sensitivity
			knob1.rotation.z = volume * -0.05
	
func update_tuning(event_rel:Vector2):
	tuning = clampf(tuning+(event_rel.x - event_rel.y) * sensitivity, 0., 50.)
	knob2.rotation.z = tuning * -0.05
	tuning_fork.position.x = lerp(-.08, .185, tuning/50.)
	var freq = lerp(50., 160., tuning/50.)
	print(freq)

func get_freq() -> float:
	var freq = lerp(50., 160., tuning/50.)
	print(freq)
	return freq
