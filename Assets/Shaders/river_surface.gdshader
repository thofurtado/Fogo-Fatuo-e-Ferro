shader_type canvas_item;
varying vec2 world_pos;
void vertex(){world_pos=(MODEL_MATRIX*vec4(VERTEX,0.0,1.0)).xy;}
void fragment(){
	float broad=sin(world_pos.y*0.035+sin(world_pos.x*0.021)*1.6-TIME*0.55);
	float ripple=sin(world_pos.y*0.33+sin(world_pos.x*0.07)*2.0-TIME*1.1);
	float broken=sin(world_pos.x*0.12+world_pos.y*0.019+TIME*0.2)*0.5+0.5;
	float highlight=smoothstep(0.87,1.0,ripple)*smoothstep(0.42,0.8,broken);
	COLOR.rgb *= 0.94 + broad*0.04;
	COLOR.rgb += vec3(0.035,0.055,0.050)*highlight;
}
