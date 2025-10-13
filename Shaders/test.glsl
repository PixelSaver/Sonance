#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) buffer DataBuffer {
    float data[];
};

layout(push_constant, std430) uniform Params {
    int grid_width;
    int grid_height;
    float time;
    float _padding;
} params;

void main() {
    ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
    if (pos.x >= params.grid_width || pos.y >= params.grid_height) return;
    int idx = pos.y * params.grid_width + pos.x;
    data[idx] = 1.0;
}
