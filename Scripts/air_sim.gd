extends Node2D

const GRID_SIZE := Vector2(32, 16)  # Small grid to start
const CELL_SIZE = 16  # Pixels per cell (for drawing)
const SHADER_FILE_PATH = "res://ignore/acoustic_wave.glsl"

var rd: RenderingDevice
var shader: RID
var pipeline: RID
var buffer: RID
var uniform_set: RID

var grid_data: PackedFloat32Array

func _ready() -> void:
	rd = RenderingServer.create_local_rendering_device()
	if not rd:
		push_error("GPU compute and rendering server not supported")
		return
	
	# THIS IS WAHT THE DOCS SAID HELP https://docs.godotengine.org/en/latest/tutorials/shaders/compute_shaders.html
	var shader_file := load(SHADER_FILE_PATH)
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	
	# Actually make input stuff
	
	
	
