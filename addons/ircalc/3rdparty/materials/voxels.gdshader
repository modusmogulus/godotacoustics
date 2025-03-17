shader_type spatial;

uniform float voxel_size : hint_range(0.01, 1.0) = 0.15; // Size of each voxel

void vertex() {
    // Get world position of the vertex
    vec3 world_pos = VERTEX * mat3(MODEL_MATRIX) + MODEL_MATRIX[3].xyz;

    // Snap to voxel grid
    world_pos = floor(world_pos / voxel_size) * voxel_size;

    // Convert back to object space
    VERTEX = (inverse(MODEL_MATRIX) * vec4(world_pos, 1.0)).xyz;
}
