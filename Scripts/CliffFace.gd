extends Node2D

@export var face_width: float = 60.0
@export var face_height: float = 360.0

func _draw():
	var rows = maxi(1, ceili(face_height / 42.0))
	var height = face_height / rows
	for row in range(rows):
		var y = -face_height * 0.5 + row * height
		var inset = 4.0 if row % 2 == 0 else -3.0
		var left = -face_width * 0.5 + inset
		var right = face_width * 0.5 + inset
		var rock = PackedVector2Array([Vector2(left + 5,y),Vector2(right - 8,y-3),Vector2(right+4,y+height*0.4),Vector2(right-5,y+height),Vector2(left,y+height-3),Vector2(left-4,y+8)])
		draw_colored_polygon(rock, Color(0.43 + (row % 3) * 0.025, 0.42, 0.32))
		draw_line(Vector2(left+4,y+4),Vector2(right-8,y+1),Color(0.65,0.60,0.44),3)
		draw_line(Vector2(right-3,y+height*0.45),Vector2(right-5,y+height-2),Color(0.26,0.29,0.19),4)
