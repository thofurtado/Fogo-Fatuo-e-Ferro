extends CharacterBody2D
class_name TropeiroPlayer

@export var speed: float = 200.0
@onready var sprite = $Sprite2D

var facing_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false
var bob_timer: float = 0.0
var is_falling_ledge: bool = false

func drop_down_ledge(target_y: float, on_finished: Callable = Callable()):
	if is_falling_ledge:
		return
	is_falling_ledge = true
	velocity = Vector2.ZERO
	
	# Hop animation no sprite (arco de salto na pedra)
	var hop = create_tween()
	hop.tween_property(sprite, "position:y", -18.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hop.tween_property(sprite, "position:y", 0.0, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Movimento para baixo até o nível inferior
	var move = create_tween()
	move.tween_property(self, "position:y", target_y, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await move.finished
	
	is_falling_ledge = false
	if on_finished.is_valid():
		on_finished.call()

func _physics_process(delta):
	if is_falling_ledge:
		return
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
		
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		facing_direction = input_vector
		velocity = input_vector * speed
		is_moving = true
		
		# Vira o sprite horizontalmente
		if input_vector.x > 0.1:
			sprite.flip_h = false
		elif input_vector.x < -0.1:
			sprite.flip_h = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * 10.0 * delta)
		is_moving = false
		
	# Move com colisão
	move_and_slide()
	
	# Empurrar objetos físicos (Barris e Caixotes - Mecânica Goofy Troop)
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is CharacterBody2D and collider.is_in_group("pushable"):
			collider.velocity = -collision.get_normal() * (speed * 0.6)
			collider.move_and_slide()
			
	# Animação sutil de passos (bobbing)
	if is_moving:
		bob_timer += delta * 12.0
		sprite.position.y = sin(bob_timer) * 2.5
	else:
		bob_timer = 0.0
		sprite.position.y = 0.0
