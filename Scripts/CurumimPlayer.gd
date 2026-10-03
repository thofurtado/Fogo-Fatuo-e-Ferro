extends CharacterBody2D

@export var speed: float = 190.0
@onready var sprite = $Sprite2D

var current_direction: String = "down"
var walk_anim_timer: float = 0.0
var current_step_col: int = 1 # 0: passo esq, 1: idle, 2: passo dir

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
		
	# Atualiza direção predominante
	if dir.y > 0:
		current_direction = "down"
	elif dir.y < 0:
		current_direction = "up"
	elif dir.x > 0:
		current_direction = "right"
	elif dir.x < 0:
		current_direction = "left"

	velocity = dir.normalized() * speed
	move_and_slide()
	
	# Animação de caminhada em 4 direções
	if velocity.length() > 5.0:
		walk_anim_timer += delta * 8.0
		var frame_cycle = int(walk_anim_timer) % 4
		# Sequência: 0 -> 1 -> 2 -> 1
		if frame_cycle == 3:
			current_step_col = 1
		else:
			current_step_col = frame_cycle
	else:
		walk_anim_timer = 0.0
		current_step_col = 1 # Posição neutra/idle
		
	_update_sprite_frame()

func _update_sprite_frame():
	var row = 0
	match current_direction:
		"down": row = 0
		"up": row = 1
		"right": row = 2
		"left": row = 3
		
	sprite.frame = row * 3 + current_step_col