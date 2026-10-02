extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(_delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1
		
	velocity = direction.normalized() * speed
	move_and_slide()
	queue_redraw()

func _draw():
	# Desenha o personagem no estilo gibi (linhas pretas fortes e cores saturadas)
	# Sombra de gota no chão
	draw_circle(Vector2(0, 15), 14, Color(0.1, 0.1, 0.1, 0.35))
	
	# Corpo / Camisa (Azul estilo gibi)
	draw_circle(Vector2(0, 2), 12, Color(0.15, 0.45, 0.85))
	draw_arc(Vector2(0, 2), 12, 0, TAU, 32, Color(0.05, 0.05, 0.05), 3.0)
	
	# Cabeça (Pele cabocla clássica: tom quente)
	draw_circle(Vector2(0, -12), 11, Color(0.96, 0.76, 0.55))
	draw_arc(Vector2(0, -12), 11, 0, TAU, 32, Color(0.05, 0.05, 0.05), 3.0)
	
	# Olhos estilo MSP clássico (pontos de nanquim preto)
	draw_circle(Vector2(-4, -13), 2.2, Color(0.05, 0.05, 0.05))
	draw_circle(Vector2(4, -13), 2.2, Color(0.05, 0.05, 0.05))
	
	# Sorriso de gibi
	draw_arc(Vector2(0, -9), 4, 0.2, PI - 0.2, 16, Color(0.05, 0.05, 0.05), 2.0)
	
	# Chapéu de palha rústico (Chico Bento / Sertão)
	var hat_points = PackedVector2Array([
		Vector2(-18, -16),
		Vector2(18, -16),
		Vector2(10, -25),
		Vector2(-10, -25)
	])
	draw_colored_polygon(hat_points, Color(0.92, 0.82, 0.35))
	draw_polyline(PackedVector2Array([
		Vector2(-18, -16), Vector2(18, -16), Vector2(10, -25), Vector2(-10, -25), Vector2(-18, -16)
	]), Color(0.05, 0.05, 0.05), 2.5)
	
	# Faixa vermelha do chapéu
	draw_line(Vector2(-12, -18), Vector2(12, -18), Color(0.85, 0.2, 0.15), 3.0)