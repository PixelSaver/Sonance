@[compute]
#version 450

// Parallel stuff running on the GPU
// 8x8 threads so 64 threads in a workgroup
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, std430) restrict buffer DataBuffer {
    float data[];
}

// Parameters passed each frame
// layout(push_constant, std430) uniform Params {
//     int grid_width;
//     int grid_height;
//     float time;
// } params;

void main() {
    // Which cell in the grid are we working on?
    ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
    
    // Check out of bounds and stuff
    if pos.x >= parans.grid_width || pos.y >= parans.grid_height) {
        return;
    }
    
    // Change 2d pos to 1d index
    int index = pos.y * params.grid_width + pos.x;
    
    // Edit the data buffer
    // Checkerboard for now
    float checker = float((pos.x + pos.y) % 2);
    data[index] = checker;
}