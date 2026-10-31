extends Node2D
var width: float = 14
var depth: float = 0.25
func _draw():
	# A soft contact shadow stays under the feet, instead of a detached oval.
	for ring in range(4, 0, -1):
		var points = PackedVector2Array()
		var radius = width * (0.65 + ring * 0.0875)
		for i in range(32):
			var angle = i * TAU / 32
			points.append(Vector2(cos(angle)*radius, sin(angle)*radius*depth))
		draw_colored_polygon(points, Color(0.025,0.04,0.018,0.045))
