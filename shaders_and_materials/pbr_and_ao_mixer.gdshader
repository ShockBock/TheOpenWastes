shader_type spatial;

// Texture inputs for the material
uniform sampler2D albedo_texture;     // The base colour texture (albedo)
uniform sampler2D roughness_texture;  // The texture controlling roughness (how shiny the material is)
uniform sampler2D normal_texture;     // The texture used to simulate surface details with normals
uniform sampler2D ao_texture;         // The texture for ambient occlusion (shadows in crevices)
uniform sampler2D noise_texture;      // The noise texture used to add variation to the material

// Controls for tweaking the material via the editor
uniform float texture_scale: hint_range(1.0, 10.0, 0.1) = 5.0;  // Scales UV coordinates for the textures
uniform float albedo_intensity: hint_range(0.0, 4.0, 0.1) = 1.0; // Controls how bright or dark the albedo is
uniform float roughness_intensity: hint_range(0.0, 1.0, 0.1) = 1.0; // Adjusts the roughness value
uniform float noise_scale: hint_range(1.0, 10.0, 0.1) = 1.0;  // Controls the scaling of the noise texture
uniform float noise_intensity: hint_range(0.0, 2.0, 0.01) = 1.0; // Lower values for darker noise
uniform float ao_intensity: hint_range(0.0, 2.0, 0.1) = 1.0;  // Controls the intensity of the ambient occlusion effect
uniform float brightness_adjust: hint_range(0.0, 3.0, 0.1) = 3.0;  // Overall brightness adjustment for the material

void fragment() {
    // Calculate UV coordinates with scaling for the main textures
    vec2 object_uv = UV * texture_scale;

    // Sample the albedo texture and apply intensity adjustments
    vec3 object_albedo = pow(texture(albedo_texture, object_uv).xyz, vec3(2.2)) * albedo_intensity;

    // Sample the roughness texture and apply intensity adjustments
    float object_roughness = texture(roughness_texture, object_uv).x * roughness_intensity;

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
	noise_value *= noise_intensity;

    // Mix the albedo with ambient occlusion (darkens areas based on occlusion)
    vec3 mixed_albedo = object_albedo * object_ao;

    // Apply noise to the albedo. Dark areas of the noise will darken the albedo,
    // light areas of the noise will have little or no effect (multiply blend).
    mixed_albedo *= mix(vec3(1.0), vec3(noise_value), noise_value);

    // Set shader outputs with brightness adjustment applied
    ALBEDO = mixed_albedo * brightness_adjust;  // Apply brightness adjustment to the final colour
    ROUGHNESS = object_roughness;  // Set the roughness (controls shininess)
    NORMAL = normalize(object_normal);  // Ensure the normal vector is normalized for proper lighting
}
