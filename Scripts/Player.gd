extends CharacterBody2D

@export var speed: float = 220.0
@onready var sprite = $Sprite2D

var walk_time: float = 0.0

func _physics_process(delta):
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
	
	# Animação de caminhada estilo cartum (balanço e inclinação leve)
	if velocity.length() > 10.0:
		walk_time += delta * 14.0
		sprite.position.y = -sin(walk_time) * 4.0
		sprite.rotation_degrees = sin(walk_time * 0.5) * 5.0
		if velocity.x < -10.0:
			sprite.flip_h = true
		elif velocity.x > 10.0:
			sprite.flip_h = false
	else:
		walk_time = 0.0
		sprite.position.y = lerp(sprite.position.y, 0.0, delta * 10.0)
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, 0.0, delta * 10.0)