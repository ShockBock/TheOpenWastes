shader_type spatial;
uniform sampler2D earth_albedo_image;
uniform sampler2D earth_normal_image;
uniform sampler2D earth_roughness_image;

uniform sampler2D rock_albedo_image;
uniform sampler2D rock_normal_image;
uniform sampler2D rock_roughness_image;

uniform float gradient_intensity : hint_range(0.0, 1.0); // Control the intensity of the gradient
uniform float transition_point : hint_range(0.0, 1.0); // Control the point of transition on the y-axis
uniform float min_height; // Minimum height of the mesh
uniform float max_height; // Maximum height of the mesh

uniform float earth_texture_scale : hint_range(0.1, 20.0); // Scale for the earth textures
uniform float rock_texture_scale : hint_range(0.1, 20.0); // Scale for the rock textures

varying float vertex_height;

void vertex() {
	// Pass the vertex height to the fragment shader
	vertex_height = VERTEX.y;
}

void fragment(){
	// Normalize the vertex height to a 0-1 range

	float height_factor = (vertex_height - min_height) / (max_height - min_height);

	// Adjust mix_factor using smoothstep to create a sharp transition around the transition_point
	float mix_factor = smoothstep(transition_point - gradient_intensity * 0.5, transition_point + gradient_intensity * 0.5, height_factor);


	// Adjust the UV coordinates based on the texture scales
	vec2 earth_uv = UV * earth_texture_scale;
	vec2 rock_uv = UV * rock_texture_scale;

	vec3 earth_albedo = texture(earth_albedo_image, earth_uv).xyz;
	vec3 earth_normal = texture(earth_normal_image, earth_uv).xyz;
	float earth_roughness = texture(earth_roughness_image, earth_uv).x;

	vec3 rock_albedo = texture(rock_albedo_image, rock_uv).xyz;
	vec3 rock_normal = texture(rock_normal_image, rock_uv).xyz;
	float rock_roughness = texture(rock_roughness_image, rock_uv).x;

	ALBEDO = mix(earth_albedo, rock_albedo, mix_factor);
	NORMAL = mix(earth_normal, rock_normal, mix_factor);
	ROUGHNESS = mix(earth_roughness, rock_roughness, mix_factor);
}