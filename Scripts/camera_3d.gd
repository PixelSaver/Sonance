extends Camera3D

@export var ray : RayCast3D
@export var canvas_target : Marker3D
@export var control : Control
@export var flashlight : SpotLight3D

func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * 100
	ray.global_position = from
	ray.target_position = to
	
	flashlight.look_at(to, Vector3.UP)
