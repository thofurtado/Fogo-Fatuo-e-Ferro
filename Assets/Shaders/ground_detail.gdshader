shader_type canvas_item;
global uniform float serra_rain;
varying vec2 world_pos;
float hash(vec2 p) {return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p) {vec2 i=floor(p);vec2 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){world_pos=(MODEL_MATRIX*vec4(VERTEX,0.0,1.0)).xy;}
void fragment(){float patches=noise(world_pos*0.018);float grain=hash(floor(world_pos*0.65));COLOR.rgb *= 0.86 + patches*0.22 + grain*0.10;COLOR.rgb*=1.0-serra_rain*0.08;}
