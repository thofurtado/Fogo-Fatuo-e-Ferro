shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform bool effect_enabled = false; // Desligado por padrão para que o jogo abra limpo e vibrante!
uniform vec4 paper_tint : source_color = vec4(0.98, 0.96, 0.91, 1.0); // Papel limpo
uniform float paper_roughness : hint_range(0.0, 1.0) = 0.04;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.15;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 col = texture(screen_texture, uv);
    
    if (effect_enabled) {
        // Leve vinheta de página impressa
        vec2 d = uv - vec2(0.5);
        float vig = 1.0 - dot(d, d) * vignette_strength;
        
        // Granulação quase imperceptível de papel nobre
        float grain = (hash(uv * 1200.0) - 0.5) * paper_roughness;
        
        // Mistura sutil com a tonalidade do papel sem escurecer os personagens
        vec3 final_rgb = col.rgb * paper_tint.rgb * vig + vec3(grain);
        COLOR = vec4(clamp(final_rgb, 0.0, 1.0), col.a);
    } else {
        COLOR = col;
    }
}