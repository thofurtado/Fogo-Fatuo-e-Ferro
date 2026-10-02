extends CharacterBody2D

@export var speed: float = 180.0
@onready var sprite = $Sprite2D

var walk_cycle: float = 0.0

func _physics_process(delta):
	var dir = Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		dir.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		dir.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		dir.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		dir.y -= 1
		
	velocity = dir.normalized() * speed
	move_and_slide()
	
	# Mantém dentro da área da tela (largura 572, altura 1024)
	position.x = clamp(position.x, 140.0, 430.0)
	position.y = clamp(position.y, 160.0, 850.0)
	
	# Animação suave
	if velocity.length() > 5.0:
		walk_cycle += delta * 12.0
		sprite.position.y = -abs(sin(walk_cycle)) * 4.0
		if velocity.x < -5.0:
			sprite.flip_h = true
		elif velocity.x > 5.0:
			sprite.flip_h = false
	else:
		walk_cycle = 0.0
		sprite.position.y = lerp(sprite.position.y, 0.0, delta * 8.0)