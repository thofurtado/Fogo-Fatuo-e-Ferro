extends Node

var is_player: bool = false
var frames: SpriteFrames
var actor: CharacterBody2D
var sprite: Sprite2D
var direction: StringName = &"south"
var timer: float = 0
var step_sound: AudioStreamPlayer2D
var last_step: int = -1
var previous_key: String = ""
var previous_position: Vector2

func _ready():
	actor = get_parent()
	sprite = actor.get_node("Sprite2D")
	sprite.scale = Vector2.ONE * (0.23 if is_player else 0.25)
	step_sound = AudioStreamPlayer2D.new()
	step_sound.stream = load("res://Assets/SFX/footstep.wav")
	step_sound.volume_db = -23 if is_player else -27
	step_sound.max_distance = 340
	actor.add_child(step_sound)
	previous_position = actor.global_position
	_apply_frame(0)
	sprite.position.y = actor.sprite_ground_y

func _physics_process(_delta):
	var displacement = actor.global_position - previous_position
	previous_position = actor.global_position
	if actor.is_falling_ledge:
		return
	# Drive the gait from distance actually travelled, including collision response.
	# A held direction against a wall must not play footsteps or run in place.
	var distance = displacement.length()
	var moving = actor.is_moving and distance > 0.001 and distance < 64
	if moving:
		var velocity = displacement
		if absf(velocity.x) > absf(velocity.y):
			direction = &"west" if velocity.x < 0 else &"east"
		else:
			direction = &"north" if velocity.y < 0 else &"south"
		timer += distance / (48.0 if is_player else 56.0)
	else:
		timer = 0
	var step = int(timer*2)
	if moving and step != last_step and not actor.is_falling_ledge:
		step_sound.pitch_scale = 1.0 if is_player else 0.8
		if DisplayServer.get_name() != "headless":
			step_sound.play()
	last_step = step
	# Mirror the complete west-facing hero cycle consistently for east.
	sprite.flip_h = is_player and direction == &"east"
	_apply_frame(int(timer * 4) % 4 if moving else 0)
	var lift = -absf(sin(timer*TAU))*1.2 if moving else 0.0
	sprite.position.y = actor.sprite_ground_y + lift + (actor.water_sink_depth if actor.in_water else 0.0)

func _apply_frame(index: int):
	var key = str(direction) + str(index)
	if key == previous_key:
		return
	previous_key = key
	sprite.texture = frames.get_frame_texture(direction,index)
	var old_y = actor.sprite_ground_y
	actor.sprite_ground_y = -sprite.texture.get_height() * sprite.scale.y * 0.5
	sprite.position.y += actor.sprite_ground_y - old_y

func _exit_tree():
	if is_instance_valid(step_sound):
		step_sound.stop()
		step_sound.stream = null
