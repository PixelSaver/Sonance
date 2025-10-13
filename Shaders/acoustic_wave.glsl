#[compute]
#version 450

// Parallel stuff running on the GPU
// 8x8 threads so 64 threads in a workgroup
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Input maps
layout(set = 0, binding = 0, std430) restrict buffer DataBuffer {
    float pressure[];
};
// Input maps
layout(set = 0, binding = 1, std430) restrict buffer VelocityXBuffer {
    float vel_x[];
};
// Input maps
layout(set = 0, binding = 2, std430) restrict buffer VelocityYBuffer {
    float vel_y[];
};

// Parameters passed each frame
layout(push_constant, std430) uniform Params {
    int grid_width;
    int grid_height;
    float time;
    // Apparently theres dumb rule that it has to be 32??? idk we'll see
    float _padding;
} params;

const float MACH_1 = 343.0; // m/s of soundwaves
const float AIR_DENSITY = 1.225; // kg/m^3
const float DX = 1.0; // Grid spacing (normalized)
const float DT = .001; // Time step
const float COURANT = MACH_1 * DT / DX; // Must be < 1 for stability (CFL condition, whatever that menas)

// 0 is no damping, 1 is full damping
const float DAMPING = 0.01;

int get_index(ivec2 pos) {
    return pos.y * params.grid_width + pos.x;
}
float sample_pressure(ivec2 pos) {
    pos = clamp(pos, ivec2(0), ivec2(params.grid_width - 1, params.grid_height - 1));
    return pressure[get_index(pos)];
}
float sample_vel_x(ivec2 pos) {
    pos = clamp(pos, ivec2(0), ivec2(params.grid_width - 1, params.grid_height - 1));
    return vel_x[get_index(pos)];
}
float sample_vel_y(ivec2 pos) {
    pos = clamp(pos, ivec2(0), ivec2(params.grid_width - 1, params.grid_height - 1));
    return vel_y[get_index(pos)];
}

void main() {
    // Which cell in the grid are we working on?
    ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
    
    // Check out of bounds and stuff
    if (pos.x >= params.grid_width || pos.y >= params.grid_height) {
        return;
    }
    
    int index = get_index(pos);
    
    // v = v + (dt / (rho * dx)) * grad(p)
    float p_center = sample_pressure(pos);
    float p_left = sample_pressure(pos + ivec2(-1, 0));
    float p_right = sample_pressure(pos + ivec2(1, 0));
    float p_top = sample_pressure(pos + ivec2(0, -1));
    float p_bottom = sample_pressure(pos + ivec2(0, 1));
    
    // Pressure gradients
    float dp_dx = (p_right - p_left) / (2.0 * DX);
    float dp_dy = (p_bottom - p_top) / (2.0 * DX);
    
    // Updating vel
    float new_vel_x = vel_x[index] - (DT / (AIR_DENSITY * DX)) * dp_dx;
    float new_vel_y = vel_y[index] - (DT / (AIR_DENSITY * DX)) * dp_dy;
    
    // p = p - (rho * c^2 * dt / dx) * div(v)
    float vel_x_left = sample_vel_x(pos + ivec2(-1, 0));
    float vel_x_right = sample_vel_x(pos + ivec2(1, 0));
    float vel_y_top = sample_vel_y(pos + ivec2(0, -1));
    float vel_y_bottom = sample_vel_y(pos + ivec2(0, 1));
    
    float div_v = ((vel_x_right - vel_x_left) + (vel_y_bottom - vel_y_top)) / (2.0 * DX);
        
    // Update pressure
    float new_pressure = pressure[index] - (AIR_DENSITY * MACH_1 * MACH_1 * DT / DX) * div_v;
    
    new_pressure *= (1.0 - DAMPING);
    
    float test_pressure = 0.0;
    
    // Add a oscillating source to see stuff change
    ivec2 source_pos = ivec2(params.grid_width / 2, params.grid_height / 2);
    if (pos == source_pos) {
        // Sine wave source
        float frequency = 100.;  // Hz (in simulation time)
        float amplitude = 1;
        float source_signal = amplitude * sin(2.0 * 3.14159 * frequency * params.time);
        test_pressure = source_signal;
    }
    
    
    pressure[index] = new_pressure + test_pressure;
    
}