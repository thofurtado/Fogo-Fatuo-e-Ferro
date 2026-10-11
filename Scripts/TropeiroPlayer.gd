extends CharacterBody2D
class_name TropeiroPlayer

@export var speed: float = 95.0
@export var camera_zoom: Vector2 = Vector2(1.35, 1.35)
@onready var sprite = $Sprite2D

var facing_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false
var bob_timer: float = 0.0
var is_falling_ledge: bool = false

# Mecânica de água / riacho
var water_zones_count: int = 0
var in_water: bool = false
var water_slow_factor: float = 1.0
var water_sink_depth: float = 0.0

func _ready():
	var cam = get_node_or_null("Camera2D") as Camera2D
	if cam:
		cam.zoom = camera_zoom

func enter_water_zone(slow_factor: float = 0.35, sink_depth: float = 3.5):
	water_zones_count += 1
	in_water = true
	water_slow_factor = slow_factor
	water_sink_depth = sink_depth

func exit_water_zone():
	water_zones_count = max(0, water_zones_count - 1)
	if water_zones_count == 0:
		in_water = false
		water_slow_factor = 1.0
		water_sink_depth = 0.0

func drop_down_ledge(target_y: float, on_finished: Callable = Callable()):
	if is_falling_ledge:
		return
	is_falling_ledge = true
	velocity = Vector2.ZERO
	
	# Hop animation no sprite (arco de salto na pedra)
	var base_y = water_sink_depth if in_water else 0.0
	var hop = create_tween()
	hop.tween_property(sprite, "position:y", base_y - 18.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hop.tween_property(sprite, "position:y", base_y, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Movimento para baixo até o nível inferior
	var move = create_tween()
	move.tween_property(self, "global_position:y", target_y, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
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
		
	var effective_speed = speed * water_slow_factor
		
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		facing_direction = input_vector
		velocity = input_vector * effective_speed
		is_moving = true
		
		# Vira o sprite horizontalmente
		if input_vector.x > 0.1:
			sprite.flip_h = false
		elif input_vector.x < -0.1:
			sprite.flip_h = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, effective_speed * 10.0 * delta)
		is_moving = false
		
	# Move com colisão
	move_and_slide()
	
	# Empurrar objetos físicos (Barris e Caixotes - Mecânica Goofy Troop)
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is CharacterBody2D and collider.is_in_group("pushable"):
			collider.velocity = -collision.get_normal() * (effective_speed * 0.6)
			collider.move_and_slide()
			
	# Animação sutil de passos (bobbing com ritmo cadenciado + imersão visual na água)
	if is_moving:
		var bob_freq = 4.5 if in_water else 7.5
		bob_timer += delta * bob_freq
		var bob_offset = sin(bob_timer) * (1.0 if in_water else 1.6)
		sprite.position.y = bob_offset + (water_sink_depth if in_water else 0.0)
	else:
		bob_timer = 0.0
		sprite.position.y = (water_sink_depth if in_water else 0.0)
