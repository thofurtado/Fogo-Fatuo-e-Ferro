shader_type canvas_item;
varying vec2 world_pos;
void vertex(){world_pos=(MODEL_MATRIX*vec4(VERTEX,0.0,1.0)).xy;}
void fragment(){float wave=sin(world_pos.y*0.14+world_pos.x*0.08-TIME*1.8);float detail=sin(world_pos.x*0.19+TIME*1.2)*0.5+0.5;float highlight=smoothstep(0.80,1.0,wave)*detail;COLOR.rgb += vec3(0.10,0.14,0.12)*highlight;}
