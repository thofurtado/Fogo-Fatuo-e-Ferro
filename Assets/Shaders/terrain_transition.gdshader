shader_type canvas_item;
global uniform float serra_rain;
varying vec2 world_pos;
uniform vec2 edge_points[32];
uniform int edge_count = 0;
uniform float feather = 18.0;
float hash(vec2 p) {return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p) {vec2 i=floor(p);vec2 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){world_pos=(MODEL_MATRIX*vec4(VERTEX,0.0,1.0)).xy;}
void fragment(){
	float distance_to_edge = 10000.0;
	for(int i=0;i<32;i++){
		if(i>=edge_count){break;}
		vec2 a=edge_points[i];vec2 b=edge_points[(i+1)%edge_count];
		vec2 ab=b-a;
		distance_to_edge=min(distance_to_edge,length(world_pos-a-ab*clamp(dot(world_pos-a,ab)/max(dot(ab,ab),0.001),0.0,1.0)));
	}
	float patches=noise(world_pos*0.025);
	COLOR.rgb *= 0.90 + patches*0.16 + hash(floor(world_pos))*0.045;
	COLOR.rgb*=1.0-serra_rain*0.08;
	COLOR.a *= smoothstep(0.0,feather,distance_to_edge-noise(world_pos*0.10)*feather*0.40);
}
