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

int get_index(ivec2 pos) {
    return pos.y * params.grid_width + pos.x;
}

void main() {
    // Which cell in the grid are we working on?
    ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
    
    // Check out of bounds and stuff
    if (pos.x >= params.grid_width || pos.y >= params.grid_height) {
        return;
    }
    
    // Change 2d pos to 1d index
    int index = get_index(pos);
    
    // Edit the data buffer
    // Checkerboard for now
    float checker = float((pos.x + pos.y) % 2);
    pressure[index] = checker;
}