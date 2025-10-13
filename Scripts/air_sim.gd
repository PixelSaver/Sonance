extends Node2D

const GRID_SIZE := Vector2i(32, 16)  # Small grid to start
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
	pipeline = rd.compute_pipeline_create(shader)
	
	# Actually make input buffer and stuff
	grid_data = PackedFloat32Array()
	grid_data.resize(GRID_SIZE.x * GRID_SIZE.y)
	grid_data.fill(0.0)
	
	# Passing in information to the shader
	# Called uniforms in glsl i think
	var uniform = RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0 # needs to match the "binding" in shader file (from docs)
	uniform.add_id(buffer)
	uniform_set = rd.uniform_set_create([uniform], shader, 0)
	
	

# The plan 
func _process(_delta: float) -> void:
	if not rd: return
	
	#run_compute_shader()
	
	#read_data_from_gpu()
	
	#queue_redraw()

func run_compute_shader():
	# Push constants AKA params AKA uniforms WHY SO MANY NAMES
	var push_constant = PackedByteArray()
	push_constant.resize(8)
	push_constant.encode_s32(0, GRID_SIZE.x)
	push_constant.encode_s32(0, GRID_SIZE.y)
	# Create a compute pipeline (from docs)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 5, 1, 1)
	rd.compute_list_end()
	
	# Submit to GPU and wait for sync
	rd.submit()
	rd.sync()
