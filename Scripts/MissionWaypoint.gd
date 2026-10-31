extends Node2D

func _draw():
	draw_circle(Vector2.ZERO, 14, Color(1, 0.82, 0.3, 0.2))
	draw_arc(Vector2.ZERO, 14, 0, TAU, 24, Color(1, 0.82, 0.3), 2, true)
	draw_colored_polygon(PackedVector2Array([Vector2(-8,-5), Vector2(8,-5), Vector2(0,8)]), Color(1,0.9,0.5))
