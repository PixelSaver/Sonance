extends RigidBody3D
class_name RadioMenuButton

signal pressed()
var og_pos : Vector3
var t : Tween
var hovered := false

func _ready() -> void:
	og_pos = global_position

func _input(event: InputEvent) -> void:
	if not hovered: return
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_click"):
			is_pressed()

func is_pressed():
	if t: t.kill()
	hovered = true
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT)
	t.tween_property(self, "global_position", og_pos + Vector3(0, -1, 0) * .01, 0.1)
	t.tween_property(self, "global_position", og_pos + Vector3(0, 1, 0) * .02, 0.1)
	
	pressed.emit()

func _on_mouse_entered():
	print("entered")
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT)
	t.tween_property(self, "global_position", og_pos + Vector3(0, 1, 0) * .02, 0.3)
	hovered = true


func _on_mouse_exited() -> void:
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT)
	t.tween_property(self, "global_position", og_pos, 0.3)
	hovered = false
