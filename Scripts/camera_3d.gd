extends Camera3D

@export var ray : RayCast3D

func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	#mouse_pos = mouse_pos /2 - Vector2.ONE / 2 
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * 100
	ray.global_position = from
	ray.target_position = to
