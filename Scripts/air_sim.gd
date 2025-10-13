extends Node2D

const GRID_SIZE := Vector2i(32, 16)  # Small grid to start
const CELL_SIZE = 32  # Pixels per cell (for drawing)
const SHADER_FILE_PATH = "res://Shaders/acoustic_wave.glsl"

var rd: RenderingDevice
var shader: RID
var pipeline: RID
var uniform_set: RID

var grid_data: PackedFloat32Array
var pressure_data: PackedFloat32Array
var vel_x_data: PackedFloat32Array
var vel_y_data: PackedFloat32Array
var buffer_p: RID
var buffer_x: RID
var buffer_y: RID

# QoL stuff
var position_offset : Vector2

func _ready() -> void:
	rd = RenderingServer.create_local_rendering_device()
	if not rd:
		push_error("GPU compute and rendering server not supported")
		return
	
	# QoL stuff
	position_offset = get_viewport_rect().size / 2
	position_offset -= Vector2(GRID_SIZE.x * CELL_SIZE, GRID_SIZE.y * CELL_SIZE) / 2.
	
	# THIS IS WAHT THE DOCS SAID HELP https://docs.godotengine.org/en/latest/tutorials/shaders/compute_shaders.html
	var shader_file := load(SHADER_FILE_PATH)
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(shader)
	
	setup_buffers()
	
	# Cycle
	run_compute_shader()
	
	read_data_from_gpu()
	
	queue_redraw()

func setup_buffers():
	# Initialize arrays
	pressure_data = PackedFloat32Array()
	pressure_data.resize(GRID_SIZE.x * GRID_SIZE.y)
	pressure_data.fill(0.0)

	vel_x_data = PackedFloat32Array()
	vel_x_data.resize(GRID_SIZE.x * GRID_SIZE.y)
	vel_x_data.fill(0.0)

	vel_y_data = PackedFloat32Array()
	vel_y_data.resize(GRID_SIZE.x * GRID_SIZE.y)
	vel_y_data.fill(0.0)

	# Create GPU storage buffers from the arrays (use their byte representations)
	var bytes_p := pressure_data.to_byte_array()
	buffer_p = rd.storage_buffer_create(bytes_p.size(), bytes_p)

	var bytes_x := vel_x_data.to_byte_array()
	buffer_x = rd.storage_buffer_create(bytes_x.size(), bytes_x)

	var bytes_y := vel_y_data.to_byte_array()
	buffer_y = rd.storage_buffer_create(bytes_y.size(), bytes_y)

	# Create RDUniform entries for each storage buffer (bindings must match shader)
	var uniform0 = RDUniform.new()
	uniform0.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform0.binding = 0
	uniform0.add_id(buffer_p)

	var uniform1 = RDUniform.new()
	uniform1.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform1.binding = 1
	uniform1.add_id(buffer_x)

	var uniform2 = RDUniform.new()
	uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform2.binding = 2
	uniform2.add_id(buffer_y)

	# Create a single uniform set that contains all three uniforms.
	uniform_set = rd.uniform_set_create([uniform0, uniform1, uniform2], shader, 0)

# The plan 
func _process(_delta: float) -> void:
	if not rd: return
	
	#run_compute_shader()
	#
	#read_data_from_gpu()
	#
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
	var output_bytes := rd.buffer_get_data(buffer_p)
	# Place data into grid, for next simulation run
	grid_data = output_bytes.to_float32_array()

# Visualize the grid
func _draw() -> void:
	for y in GRID_SIZE.y:
		for x in GRID_SIZE.x:
			var index = y * GRID_SIZE.x + x
			var value = pressure_data[index]
			
			# Map a value 0-1 with greyscale
			var color = Color(value, value, value, 1.0)
			
			var rect = Rect2(x * CELL_SIZE + position_offset.x, y * CELL_SIZE + position_offset.y, CELL_SIZE - 1, CELL_SIZE - 1)
			draw_rect(rect, color)

# Cleanup just in case
func _exit_tree():
	if rd:
		rd.free_rid(buffer_p)
		rd.free_rid(buffer_x)
		rd.free_rid(buffer_y)
		rd.free_rid(uniform_set)
		rd.free_rid(pipeline)
		rd.free_rid(shader)
		rd.free()
