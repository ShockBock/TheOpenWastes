shader_type spatial;
uniform sampler2D rock_texture;
uniform sampler2D concrete_texture;
uniform float gradient_intensity : hint_range(0.0, 1.0); // Control the intensity of the gradient
uniform float transition_point : hint_range(0.0, 1.0); // Control the point of transition on the y-axis
uniform float min_height; // Minimum height of the mesh
uniform float max_height; // Maximum height of the mesh

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
	
	vec3 rock_albedo = texture(rock_texture, UV).xyz;
	vec3 concrete_albedo = texture(concrete_texture, UV).xyz;
	ALBEDO = mix(rock_albedo, concrete_albedo, mix_factor);
}