shader_type fog;

// --- EXPOSED TO INSPECTOR ---
uniform sampler3D noise_texture;
uniform float density_multiplier : hint_range(0.0, 10.0) = 1.0;
uniform vec3 wind_velocity = vec3(0.1, 0.0, 0.1);
uniform float noise_scale = 0.01;
uniform float edge_fade_power = 2.0;

void fog() {
    // 1. Get the world position and scale it down. 
    // Without this, the noise is microscopic.
    vec3 coords = WORLD_POSITION * noise_scale;
    
    // 2. Add time-based movement based on wind direction/speed.
    coords += wind_velocity * TIME;
    
    // 3. Sample the 3D noise texture. 
    // The 'r' pulls the red channel value (0.0 to 1.0).
    float noise = texture(noise_texture, coords).r;
    
    // 4. Smooth out the edges using the Signed Distance Field (SDF).
    // SDF gives the distance to the edge of the FogVolume.
    // By dividing it by edge_fade_power and clamping, we get a smooth 0-to-1 gradient near the edges.
    float fade = clamp(SDF / edge_fade_power, 0.0, 1.0);
    
    // 5. Output the final density.
    DENSITY = noise * density_multiplier * fade;
    
    // Optional: Uncomment the next line to give the fog a dusty desert tint, overriding the global fog color.
    // ALBEDO = vec3(0.7, 0.6, 0.4); 
}