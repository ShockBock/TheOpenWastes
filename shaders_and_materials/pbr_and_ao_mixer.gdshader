shader_type spatial;

// === Albedo Settings ===
uniform sampler2D albedo_texture;     // The base colour texture (albedo)
uniform float albedo_intensity: hint_range(0.0, 4.0, 0.1) = 1.0; // Controls how bright or dark the albedo is
uniform float albedo_red: hint_range(0.0, 2.0, 0.1) = 1.0;   // Adjusts the red channel of the albedo
uniform float albedo_green: hint_range(0.0, 2.0, 0.1) = 1.0; // Adjusts the green channel of the albedo
uniform float albedo_blue: hint_range(0.0, 2.0, 0.1) = 1.0;  // Adjusts the blue channel of the albedo

// === Roughness Settings ===
uniform sampler2D roughness_texture;  // The texture controlling roughness (how shiny the material is)
uniform float roughness_value: hint_range(0.0, 1.0, 0.1) = 0.5; // Default roughness value if no texture is assigned
uniform bool use_roughness_texture = true; // Toggle to use roughness texture or a slider value

// === Normal Map Settings ===
uniform sampler2D normal_texture;     // The texture used to simulate surface details with normals

// === Ambient Occlusion (AO) Settings ===
uniform sampler2D ao_texture;         // The texture for ambient occlusion (shadows in crevices)
uniform float ao_intensity: hint_range(0.0, 2.0, 0.1) = 1.0;  // Controls the intensity of the ambient occlusion effect

// === Noise Settings ===
uniform sampler2D noise_texture;      // The noise texture used to add variation to the material
uniform float noise_scale: hint_range(1.0, 10.0, 0.1) = 1.0;  // Controls the scaling of the noise texture
uniform float noise_intensity: hint_range(0.0, 2.0, 0.01) = 1.0; // Lower values for darker noise

// === Metalness Settings ===
uniform sampler2D metalness_texture;  // The texture controlling the metallic properties of the material
uniform float metalness_value: hint_range(0.0, 1.0, 0.1) = 0.0; // Default metalness value if no texture is assigned
uniform bool use_metalness_texture = false; // Toggle to use the metalness texture or a slider value

// === General Material Settings ===
uniform float texture_scale: hint_range(1.0, 10.0, 0.1) = 5.0;  // Scales UV coordinates for the textures
uniform float brightness_adjust: hint_range(0.0, 3.0, 0.1) = 3.0;  // Overall brightness adjustment for the material

void fragment() {
	// Calculate UV coordinates with scaling for the main textures
	vec2 object_uv = UV * texture_scale;

	// Always use the albedo texture combined with the R, G, and B sliders
	vec3 object_albedo = pow(texture(albedo_texture, object_uv).xyz, vec3(2.2)) * albedo_intensity;
	object_albedo.r *= albedo_red;
	object_albedo.g *= albedo_green;
	object_albedo.b *= albedo_blue;

	// Sample the roughness texture or use the uniform value
	float object_roughness = use_roughness_texture
		? texture(roughness_texture, object_uv).x * roughness_value
		: roughness_value;

	// Sample the normal texture, unpack it, and normalize it for proper lighting
	vec3 object_normal = texture(normal_texture, object_uv).xyz * 2.0 - 1.0;

	// Sample the ambient occlusion (AO) texture
	vec3 object_ao = texture(ao_texture, UV).xyz;

	// Apply AO intensity control
	object_ao = mix(vec3(1.0), object_ao, ao_intensity);  // Adjust the strength of the AO effect

	// Calculate the UV coordinates for the noise texture, with separate scaling
	vec2 noise_uv = UV * noise_scale;

	// Sample the noise texture (grayscale) and use only the red channel
	float noise_value = texture(noise_texture, noise_uv).r;
	noise_value *= noise_intensity;  // Apply the noise intensity

	// Mix the albedo with ambient occlusion (darkens areas based on occlusion)
	vec3 mixed_albedo = object_albedo * object_ao;

	// Apply noise to the albedo. Dark areas of the noise will darken the albedo,
	// light areas of the noise will have little or no effect (multiply blend).
	mixed_albedo *= mix(vec3(1.0), vec3(noise_value), noise_value);

	// Use either the metalness texture or the fallback metalness_value based on use_metalness_texture
	float object_metalness = use_metalness_texture
		? texture(metalness_texture, object_uv).x
		: metalness_value;

	// Set shader outputs with brightness adjustment applied
	ALBEDO = mixed_albedo * brightness_adjust;  // Apply brightness adjustment to the final colour
	ROUGHNESS = object_roughness;  // Set the roughness (controls shininess)
	NORMAL = normalize(object_normal);  // Ensure the normal vector is normalized for proper lighting
	METALLIC = object_metalness;  // Apply the metallic map or default value
}
