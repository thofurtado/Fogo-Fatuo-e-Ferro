shader_type canvas_item;
varying vec2 world_pos;
uniform vec2 path_points[40];
uniform int point_count = 0;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p);vec2 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){world_pos=(MODEL_MATRIX*vec4(VERTEX,0.0,1.0)).xy;}
void fragment(){
	float d=10000.0;
	for(int i=0;i<39;i++){
		if(i>=point_count-1){break;}
		vec2 a=path_points[i];vec2 ab=path_points[i+1]-a;
		d=min(d,length(world_pos-a-ab*clamp(dot(world_pos-a,ab)/max(dot(ab,ab),0.001),0.0,1.0)));
	}
	float edge=noise(world_pos*0.14)*3.0+noise(world_pos*0.035)*3.0;
	float worn=1.0-smoothstep(14.0,28.0,d+edge);
	vec3 soil=mix(vec3(0.36,0.34,0.21),vec3(0.60,0.47,0.31),worn);
	float rut=1.0-smoothstep(1.0,3.0,abs(d-9.0));
	soil*=1.0-rut*0.08;
	soil*=0.94+noise(world_pos*0.06)*0.10+hash(floor(world_pos))*0.045;
	COLOR.rgb=soil;
	COLOR.a*=1.0-smoothstep(22.0,29.0,d+edge);
}
