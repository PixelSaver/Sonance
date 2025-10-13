extends Node2D

const GRID_SIZE := Vector2i(32, 16)  # Small grid to start
const CELL_SIZE = 16  # Pixels per cell (for drawing)
const SHADER_FILE_PATH = "res://Shaders/acoustic_wave.glsl"

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
	
	# Forgot to make the actual buffer...
	var bytes = grid_data.to_byte_array()
	buffer = rd.storage_buffer_create(bytes.size(), bytes)
	
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
	
	run_compute_shader()
	
	read_data_from_gpu()
	
	#queue_redraw()

func run_compute_shader():
	# Push constants AKA params AKA uniforms WHY SO MANY NAMES
	var push_constant = PackedByteArray()
	# Apparently theres rules, you have to do this in 16...
	push_constant.resize(16)
	push_constant.encode_s32(0, GRID_SIZE.x)
	push_constant.encode_s32(4, GRID_SIZE.y)
	push_constant.encode_float(8, Time.get_ticks_msec())
	
	# Create a compute pipeline (from docs)
	# Leymans terms: RUN THE SHADER RHAHHH
	var compute_list : int = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())
	
	# Dispatch AKA GOOOOOOOO but 8x8 threads for now
	var groups_x := ceili(float(GRID_SIZE.x) / 8.0)
	var groups_y := ceili(float(GRID_SIZE.y) / 8.0)
	rd.compute_list_dispatch(compute_list, groups_x, groups_y, 1)
	
	# Submit to GPU and wait for sync
	rd.compute_list_end()
	rd.submit()
	rd.sync()

func read_data_from_gpu():
	# From the docs, read output
	var output_bytes := rd.buffer_get_data(buffer)
	# Place data into grid, for next simulation run
	grid_data = output_bytes.to_float32_array()
