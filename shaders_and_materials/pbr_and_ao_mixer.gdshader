shader_type spatial;

// === Albedo Settings ===
uniform sampler2D albedo_texture;     // The base colour texture (albedo)
uniform float albedo_intensity : hint_range(0.0, 4.0, 0.1) = 1.0; // Controls brightness of the albedo
uniform float albedo_red      : hint_range(0.0, 2.0, 0.1) = 1.0;   // Adjusts red channel
uniform float albedo_green    : hint_range(0.0, 2.0, 0.1) = 1.0; // Adjusts green channel
uniform float albedo_blue     : hint_range(0.0, 2.0, 0.1) = 1.0;  // Adjusts blue channel

// === Roughness Settings ===
uniform sampler2D roughness_texture;  // Texture controlling roughness
uniform float roughness_value : hint_range(0.0, 1.0, 0.1) = 0.5; // Default roughness value
uniform bool use_roughness_texture = true; // Toggle to use texture or slider

// === Normal Map Settings ===
uniform sampler2D normal_texture;     // Normal map texture

// === Ambient Occlusion (AO) Settings ===
uniform sampler2D ao_texture;         // Ambient occlusion texture
uniform float ao_intensity : hint_range(0.0, 2.0, 0.1) = 1.0;  // AO intensity

// === Noise Settings ===
uniform sampler2D noise_texture;      // Noise texture
uniform float noise_scale     : hint_range(1.0, 10.0, 0.1) = 1.0;  // Noise texture scaling
uniform float noise_intensity : hint_range(0.0, 2.0, 0.01) = 1.0; // Noise intensity

// === Metalness Settings ===
uniform sampler2D metalness_texture;  // Metalness texture
uniform float metalness_value : hint_range(0.0, 1.0, 0.1) = 0.0; // Default metalness value
uniform bool use_metalness_texture = false; // Toggle to use texture or slider

// === General Material Settings ===
uniform float texture_scale     : hint_range(1.0, 10.0, 0.1) = 5.0; // Texture scaling
uniform float brightness_adjust : hint_range(0.0, 3.0, 0.1) = 3.0;  // Overall brightness

// === UV Map Selection ===
uniform bool use_uv2 = false; // Toggle to use UV2 instead of UV1

void fragment() {
	// Select the UV map based on the user's choice
	vec2 selected_uv = use_uv2 ? UV2 : UV;

	// Calculate UV coordinates with scaling for main textures
	vec2 object_uv = selected_uv * texture_scale;

	// Sample the albedo texture and apply intensity adjustments
	vec3 object_albedo = pow(texture(albedo_texture, object_uv).rgb, vec3(2.2)) * albedo_intensity;

	// Adjust the albedo based on the R, G, B sliders
	object_albedo.r *= albedo_red;
	object_albedo.g *= albedo_green;
	object_albedo.b *= albedo_blue;

	// Sample the roughness texture or use the uniform value
	float object_roughness = use_roughness_texture
		? texture(roughness_texture, object_uv).r * roughness_value
		: roughness_value;

	// Sample the normal texture, unpack it, and normalize it
	vec3 object_normal = texture(normal_texture, object_uv).rgb * 2.0 - 1.0;
	object_normal = normalize(object_normal);

	// Sample the ambient occlusion texture using unscaled UVs
	vec3 object_ao = texture(ao_texture, selected_uv).rgb;

	// Apply AO intensity control
	object_ao = mix(vec3(1.0), object_ao, ao_intensity);

	// Calculate UV coordinates for the noise texture
	vec2 noise_uv = selected_uv * noise_scale;

	// Sample the noise texture and apply intensity
	float noise_value = texture(noise_texture, noise_uv).r * noise_intensity;

	// Mix the albedo with AO and noise
	vec3 mixed_albedo = object_albedo * object_ao;
	mixed_albedo *= mix(vec3(1.0), vec3(noise_value), noise_value);

	// Use either the metalness texture or the default value
	float object_metalness = use_metalness_texture
		? texture(metalness_texture, object_uv).r
		: metalness_value;

	// Set shader outputs with brightness adjustment
	ALBEDO = mixed_albedo * brightness_adjust;
	ROUGHNESS = object_roughness;
	NORMAL = object_normal;
	METALLIC = object_metalness;
}
