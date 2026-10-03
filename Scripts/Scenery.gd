extends Node2D

func _draw():
	# Fundo: Chão de terra batida e capim
	draw_rect(Rect2(-1000, -1000, 3000, 3000), Color(0.85, 0.78, 0.55)) # Terra clara
	
	# Manchas de grama estilo gibi (massa verde contínua com contorno)
	var grass_patch = PackedVector2Array([
		Vector2(100, 150), Vector2(350, 120), Vector2(480, 200),
		Vector2(420, 380), Vector2(200, 420), Vector2(80, 300)
	])
	draw_colored_polygon(grass_patch, Color(0.35, 0.72, 0.32))
	draw_polyline(grass_patch + PackedVector2Array([grass_patch[0]]), Color(0.08, 0.08, 0.08), 2.5)
	
	# Tufos de capim (3 riscos simples em leque clássicos)
	var tufts = [Vector2(150, 200), Vector2(250, 300), Vector2(600, 180), Vector2(700, 450), Vector2(300, 520)]
	for t in tufts:
		draw_line(t, t + Vector2(-6, -14), Color(0.1, 0.35, 0.1), 2.0)
		draw_line(t, t + Vector2(0, -18), Color(0.1, 0.35, 0.1), 2.0)
		draw_line(t, t + Vector2(6, -14), Color(0.1, 0.35, 0.1), 2.0)
		
	# Cerca de pau a pique colonial
	for i in range(5):
		var post_x = 450 + i * 55
		draw_rect(Rect2(post_x, 80, 10, 45), Color(0.48, 0.32, 0.18))
		draw_rect(Rect2(post_x, 80, 10, 45), Color(0.05, 0.05, 0.05), false, 2.0)
	draw_line(Vector2(440, 92), Vector2(685, 92), Color(0.48, 0.32, 0.18), 6.0)
	draw_line(Vector2(440, 92), Vector2(685, 92), Color(0.05, 0.05, 0.05), 2.0)
	draw_line(Vector2(440, 112), Vector2(685, 112), Color(0.48, 0.32, 0.18), 6.0)
	draw_line(Vector2(440, 112), Vector2(685, 112), Color(0.05, 0.05, 0.05), 2.0)

	# Árvores tropicais em nuvem (simplificação da mata brasileira)
	draw_tree(Vector2(850, 220), 1.1)
	draw_tree(Vector2(180, 140), 0.9)
	draw_tree(Vector2(950, 480), 1.3)

func draw_tree(pos: Vector2, scale_factor: float):
	# Tronco orgânico
	var trunk = PackedVector2Array([
		pos + Vector2(-15, 60) * scale_factor,
		pos + Vector2(15, 60) * scale_factor,
		pos + Vector2(8, 0) * scale_factor,
		pos + Vector2(-8, 0) * scale_factor
	])
	draw_colored_polygon(trunk, Color(0.42, 0.28, 0.16))
	draw_polyline(trunk + PackedVector2Array([trunk[0]]), Color(0.05, 0.05, 0.05), 2.5)
	
	# Copa da árvore: "Nuvem verde" de círculos sobrepostos com contorno unificado
	var foliage_circles = [
		Vector2(0, -30), Vector2(-35, -20), Vector2(35, -20),
		Vector2(-25, 5), Vector2(25, 5), Vector2(0, 0)
	]
	# Preenchimento verde-mata clássico
	for c in foliage_circles:
		draw_circle(pos + c * scale_factor, 38 * scale_factor, Color(0.18, 0.58, 0.24))
	# Contorno de nanquim das nuvens
	for c in foliage_circles:
		draw_arc(pos + c * scale_factor, 38 * scale_factor, 0, TAU, 24, Color(0.05, 0.05, 0.05), 2.5)