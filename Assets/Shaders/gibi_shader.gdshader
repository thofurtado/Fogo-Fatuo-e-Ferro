shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform bool effect_enabled = true;
uniform vec4 paper_tint : source_color = vec4(0.95, 0.92, 0.84, 1.0);
uniform float paper_roughness : hint_range(0.0, 1.0) = 0.12;
uniform float dots_scale : hint_range(50.0, 400.0) = 160.0;
uniform float misregistration_x : hint_range(-5.0, 5.0) = 1.0;
uniform float misregistration_y : hint_range(-5.0, 5.0) = -0.6;

vec2 rotate_uv(vec2 uv, float angle_degrees) {
    float r = radians(angle_degrees);
    float c = cos(r);
    float s = sin(r);
    mat2 rot = mat2(vec2(c, -s), vec2(s, c));
    return rot * (uv - 0.5) + 0.5;
}

float get_halftone_dot(vec2 uv, float angle, float density, float scale) {
    vec2 rot_uv = rotate_uv(uv, angle);
    vec2 grid = fract(rot_uv * scale) - 0.5;
    float dist = length(grid);
    float radius = sqrt(clamp(density, 0.0, 1.0)) * 0.55; 
    return smoothstep(radius + 0.08, radius - 0.02, dist);
}

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
    vec2 screen_uv = SCREEN_UV;
    vec2 pixel_size = SCREEN_PIXEL_SIZE;
    vec4 original_color = texture(screen_texture, screen_uv);
    
    if (!effect_enabled) {
        COLOR = original_color;
    } else {
        vec2 color_offset = vec2(misregistration_x, misregistration_y) * pixel_size;
        vec4 color_sample = texture(screen_texture, screen_uv + color_offset);
        vec4 lineart_sample = texture(screen_texture, screen_uv);
        
        vec3 cmy = vec3(1.0) - color_sample.rgb;
        cmy = floor(cmy * 3.0 + 0.5) / 3.0;
        
        float cyan_dot    = get_halftone_dot(screen_uv, 15.0, cmy.r, dots_scale);
        float magenta_dot = get_halftone_dot(screen_uv, 75.0, cmy.g, dots_scale);
        float yellow_dot  = get_halftone_dot(screen_uv,  0.0, cmy.b, dots_scale);
        
        float key_ink = 1.0 - min(min(lineart_sample.r, lineart_sample.g), lineart_sample.b);
        key_ink = smoothstep(0.4, 0.8, key_ink);
        
        vec3 printed_ink = vec3(1.0);
        printed_ink *= mix(vec3(1.0), vec3(0.0, 0.8, 0.9), cyan_dot * cmy.r);
        printed_ink *= mix(vec3(1.0), vec3(0.9, 0.0, 0.5), magenta_dot * cmy.g);
        printed_ink *= mix(vec3(1.0), vec3(0.95, 0.9, 0.0), yellow_dot * cmy.b);
        printed_ink = mix(printed_ink, vec3(0.06, 0.06, 0.06), key_ink);
        
        float paper_grain = hash(screen_uv * 700.0) * paper_roughness;
        vec3 final_paper = paper_tint.rgb - vec3(paper_grain);
        
        COLOR = vec4(printed_ink * final_paper, original_color.a);
    }
}