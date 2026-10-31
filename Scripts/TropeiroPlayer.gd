extends CharacterBody2D
class_name TropeiroPlayer

@export var speed: float = 120.0
@export var camera_zoom: Vector2 = Vector2(1.15, 1.15)
@onready var sprite = $Sprite2D

var virtual_direction: Vector2 = Vector2.ZERO
var travel_speed_factor: float = 1.0
var input_blocked: bool = false
var facing_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false
var bob_timer: float = 0.0
var sprite_ground_y: float = -18.0
var is_falling_ledge: bool = false
var directional_animator: Node
var leash_velocity: Vector2 = Vector2.ZERO
var leash_time: float = 0.0

func apply_leash_pull(pull: Vector2, duration: float = 0.18):
	if input_blocked or is_falling_ledge:
		return
	leash_velocity = pull.limit_length(75)
	leash_time = duration

# Mecânica de água / riacho
var water_zones_count: int = 0
var in_water: bool = false
var water_slow_factor: float = 1.0
var water_sink_depth: float = 0.0

func _ready():
	sprite_ground_y = sprite.position.y
	var animator = preload("res://Scripts/DirectionalAnimator.gd").new()
	directional_animator = animator
	animator.is_player = true
	animator.frames = preload("res://Assets/Sprites/Characters/hero_walk.tres")
	add_child(animator)
	var cam = get_node_or_null("Camera2D") as Camera2D
	if cam:
		cam.zoom = camera_zoom
		cam.position.y = -70

func get_rein_anchor() -> Vector2:
	var direction = directional_animator.direction if directional_animator else &"south"
	var hand_x = {&"south":-10.0,&"north":9.0,&"west":-8.0,&"east":8.0}[direction]
	var height = sprite.texture.get_height()*sprite.scale.y
	return global_position+Vector2(hand_x,sprite.position.y+height*0.10)

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
		leash_time = 0
		leash_velocity = Vector2.ZERO
		return
	is_falling_ledge = true
	leash_time = 0
	leash_velocity = Vector2.ZERO
	velocity = Vector2.ZERO
	
	# Hop animation no sprite (arco de salto na pedra)
	var base_y = sprite_ground_y + (water_sink_depth if in_water else 0.0)
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
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	input_vector.x += int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A))
	input_vector.y += int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))
	input_vector += virtual_direction
	if input_blocked:
		input_vector = Vector2.ZERO
		velocity = Vector2.ZERO
		leash_time = 0
		leash_velocity = Vector2.ZERO
	var effective_speed = speed * water_slow_factor * travel_speed_factor
		
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.limit_length(1.0)
		facing_direction = input_vector
		velocity = input_vector * effective_speed
		is_moving = true
		

	else:
		# The rein is an external velocity, not acceleration accumulated each frame.
		velocity = Vector2.ZERO if leash_time > 0 else velocity.move_toward(Vector2.ZERO, effective_speed * 10.0 * delta)
		is_moving = false
		
	if leash_time > 0:
		leash_time = maxf(0,leash_time-delta)
		velocity += leash_velocity
		is_moving = true
	else:
		leash_velocity = Vector2.ZERO
	# Move com colisão
	move_and_slide()
	
	# Empurrar objetos físicos (Barris e Caixotes - Mecânica Goofy Troop)
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is CharacterBody2D and collider.is_in_group("pushable"):
			collider.velocity = -collision.get_normal() * (effective_speed * 0.6)
			collider.move_and_slide()
