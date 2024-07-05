shader_type spatial;
// Don't know what the next line does, but might be important
// render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec4 bullet_tracer : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float bullet_emission = 20.0; // Bullet emission intensity
uniform float fade_attenuation = 1.5;

void vertex() {
	// Pass the vertex position to the colour output
	COLOR.rgb = VERTEX;
}

void fragment() {
	// Set the base colour to the bullet tracer colour
	vec3 base_color = bullet_tracer.rgb;
	
	// Apply the emission intensity to the base colour
	vec3 final_color = base_color * bullet_emission;
	
	// Breaking down the alpha calculation into multiple steps
	// Extract the blue (i.e. z-axis) channel from the COLOR input
	float blue_channel = COLOR.b;         
	// Take the absolute value of the blue (i.e. z-axis) channel
	float abs_blue = abs(blue_channel);
	// Calculate the alpha value using the power function     
	float alpha_value = pow(abs_blue, fade_attenuation);  
	
	// Set the final output colour and alpha
	ALBEDO = final_color;
	ALPHA = alpha_value;
}
