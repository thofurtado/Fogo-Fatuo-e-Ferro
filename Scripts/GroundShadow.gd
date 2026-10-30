extends Node2D
var width: float = 14
func _draw():
	var points = PackedVector2Array()
	for i in range(24):
		var angle = i * TAU / 24
		points.append(Vector2(cos(angle)*width, sin(angle)*width*0.28 + 5))
	draw_colored_polygon(points, Color(0.03,0.055,0.025,0.22))
