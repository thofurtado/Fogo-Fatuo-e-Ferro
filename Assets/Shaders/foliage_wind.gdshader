shader_type canvas_item;
global uniform float serra_wind;
global uniform float serra_rain;
uniform float sprite_height = 499.0;
uniform float sway_pixels = 7.0;
void vertex(){
	float weight=pow(clamp(0.5-VERTEX.y/sprite_height,0.0,1.0),2.0);
	float phase=MODEL_MATRIX[3].x*0.013+MODEL_MATRIX[3].y*0.009;
	VERTEX.x+=(sin(TIME*1.7+phase)+sin(TIME*3.1+phase)*0.25)*sway_pixels*serra_wind*weight;
}
void fragment(){COLOR.rgb*=1.0-serra_rain*0.07;}
