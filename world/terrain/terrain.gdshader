shader_type spatial;

uniform sampler2D earth_albedo_image;
uniform sampler2D earth_normal_image;
uniform sampler2D earth_roughness_image;

uniform sampler2D rock_albedo_image;
uniform sampler2D rock_normal_image;
uniform sampler2D rock_roughness_image;

uniform float gradient_intensity : hint_range(0.0, 1.0);
uniform float transition_point : hint_range(0.0, 1.0);
uniform float min_height;
uniform float max_height;

uniform float earth_texture_scale : hint_range(0.1, 20.0);
uniform float rock_texture_scale : hint_range(0.1, 20.0);
// Metres covered by a texture scale of 1. Textures are mapped in world
// space so they tile seamlessly across terrain chunks.
uniform float texture_world_size = 64.0;

varying float vertex_height;
varying vec2 world_uv;

void vertex() {
    vertex_height = VERTEX.y;
    world_uv = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz / texture_world_size;
}

void fragment() {
    // Clamp height factor
    float height_factor = clamp(
        (vertex_height - min_height) / (max_height - min_height),
        0.0,
        1.0
    );

    // Smooth transition
    float mix_factor = smoothstep(
        transition_point - gradient_intensity * 0.5,
        transition_point + gradient_intensity * 0.5,
        height_factor
    );

    // Scaled UVs
    vec2 earth_uv = world_uv * earth_texture_scale;
    vec2 rock_uv = world_uv * rock_texture_scale;

    // Earth textures
    vec3 earth_albedo = texture(earth_albedo_image, earth_uv).rgb;
    vec3 earth_normal_raw = texture(earth_normal_image, earth_uv).rgb;
    float earth_roughness = texture(earth_roughness_image, earth_uv).r;

    // Rock textures
    vec3 rock_albedo = texture(rock_albedo_image, rock_uv).rgb;
    vec3 rock_normal_raw = texture(rock_normal_image, rock_uv).rgb;
    float rock_roughness = texture(rock_roughness_image, rock_uv).r;

    // Blend
    ALBEDO = mix(earth_albedo, rock_albedo, mix_factor);
    NORMAL_MAP = mix(earth_normal_raw, rock_normal_raw, mix_factor);
    ROUGHNESS = mix(earth_roughness, rock_roughness, mix_factor);
}
