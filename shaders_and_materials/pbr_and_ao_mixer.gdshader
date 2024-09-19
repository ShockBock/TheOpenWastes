shader_type spatial;

// Texture inputs for the material
uniform sampler2D albedo_texture;     // The base colour texture (albedo)
uniform sampler2D roughness_texture;  // The texture controlling roughness (how shiny the material is)
uniform sampler2D normal_texture;     // The texture used to simulate surface details with normals
uniform sampler2D ao_texture;         // The texture for ambient occlusion (shadows in crevices)
uniform sampler2D noise_texture;      // The noise texture used to add variation to the albedo

// Controls for tweaking the material via the editor
uniform float noise_scale: hint_range(1.0, 10.0, 0.1) = 1.0;    // Scales UV coordinates for the noise texture
uniform float noise_intensity: hint_range(0.0, 1.0, 0.1) = 1.0;    // Intensity of the noise effect on the albedo
uniform float albedo_intensity: hint_range(0.0, 4.0, 0.1) = 4.0; // Controls how bright or dark the albedo is
uniform float roughness_intensity: hint_range(0.0, 1.0, 0.1) = 1.0; // Adjusts the roughness value
uniform float brightness_adjust: hint_range(0.0, 3.0, 0.1) = 1.0;  // Overall brightness adjustment for the material
uniform float texture_scale: hint_range(1.0, 10.0, 0.1) = 5.0;  // Scales UV coordinates for the main textures

void fragment() {
	// Calculate UV coordinates with scaling for main textures and noise texture
	vec2 object_uv = UV * texture_scale;
	vec2 noise_uv = UV * noise_scale;

	// Sample the textures
	vec3 object_albedo = pow(texture(albedo_texture, object_uv).xyz, vec3(2.2)) * albedo_intensity; // Get albedo (colour) and apply intensity
	float object_roughness = texture(roughness_texture, object_uv).x * roughness_intensity; // Get roughness value and apply intensity
	vec3 object_normal = texture(normal_texture, object_uv).xyz * 2.0 - 1.0;  // Unpack normal map (from [0,1] to [-1,1] range)
	vec3 object_ao = texture(ao_texture, UV).xyz;  // Sample ambient occlusion texture (no scaling applied)

	// Sample the noise texture (darkens the albedo in dark areas)
	float noise_value = texture(noise_texture, noise_uv).r;  // Use the red channel of the noise texture
	
	// Adjust noise intensity and ensure the noise only darkens the albedo (multiply-like effect)
	vec3 noise_effect = mix(vec3(1.0), vec3(noise_value), noise_intensity);  // Lerp between no effect and noise based on intensity
	
	// Mix the albedo with ambient occlusion and noise (dark areas from AO and noise darken the albedo)
	vec3 mixed_albedo = object_albedo * object_ao * noise_effect;

	// Apply the final adjustments to the material properties
	ALBEDO = mixed_albedo * brightness_adjust;  // Apply brightness adjustment to the final colour
	ROUGHNESS = object_roughness;  // Set the roughness (controls shininess)
	NORMAL = normalize(object_normal);  // Ensure the normal vector is normalized for proper lighting
}
