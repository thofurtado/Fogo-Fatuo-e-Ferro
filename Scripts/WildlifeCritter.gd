extends CharacterBody2D

enum State { FORAGING, ALERT, FLEEING, HIDDEN }
var kind: String = "frog"
var manager: Node
var cover: Vector2
var home: Vector2
var state: State = State.FORAGING
var state_time: float = 0.0
var clock: float = 0.0
var away: Vector2 = Vector2.LEFT
var sprite: Sprite2D
var sound: AudioStreamPlayer2D
var shadow: Node2D
var flee_count: int = 0
var rng = RandomNumberGenerator.new()
var walk_frames: Array[Texture2D] = []

func _ready():
	home = global_position
	rng.seed = int(home.x*11+home.y)
	clock = rng.randf_range(0,10)
	state_time = rng.randf_range(1,3)
	collision_layer = 0
	collision_mask = 0 if kind in ["bird","marmoset"] else 1
	var shape_node = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 3
	shape_node.shape = shape
	add_child(shape_node)
	sprite = Sprite2D.new()
	add_child(sprite)
	match kind:
		"snake": walk_frames = [preload("res://Assets/Sprites/Fauna/snake_0.tres"),preload("res://Assets/Sprites/Fauna/snake_1.tres")]
		"bird": walk_frames = [preload("res://Assets/Sprites/Fauna/bird_0.tres"),preload("res://Assets/Sprites/Fauna/bird_1.tres")]
		"frog": walk_frames = [preload("res://Assets/Sprites/Fauna/frog.tres")]
		"marmoset": walk_frames = [preload("res://Assets/Sprites/Fauna/marmoset.tres")]
	sprite.texture = walk_frames[0]
	var width = {"snake":34.0,"bird":38.0,"frog":17.0,"marmoset":41.0}[kind]
	sprite.scale = Vector2.ONE * width / sprite.texture.get_width()
	shadow = preload("res://Scripts/GroundShadow.gd").new()
	shadow.width = 7 if kind != "frog" else 4
	shadow.z_index = -1
	add_child(shadow)
	sound = AudioStreamPlayer2D.new()
	sound.stream = preload("res://Assets/SFX/wildlife_flutter.wav") if kind == "bird" else preload("res://Assets/SFX/wildlife_frog.wav")
	sound.volume_db = -24 if kind == "bird" else -28
	sound.max_distance = 300
	add_child(sound)
	_update_visual()

func _physics_process(delta):
	if not manager.enabled:
		return
	clock += delta
	state_time -= delta
	var scene = manager.scene
	if state == State.HIDDEN:
		if state_time <= 0 and home.distance_to(scene.player.global_position) > 160 and home.distance_to(scene.mula.global_position) > 160:
			global_position = home
			state = State.FORAGING
			state_time = rng.randf_range(2,5)
			show()
		return
	if global_position.distance_to(scene.player.global_position) > 700:
		return
	if kind == "snake": manager.snake_near(self)
	var player_distance = global_position.distance_to(scene.player.global_position)
	var mule_distance = global_position.distance_to(scene.mula.global_position)
	var radius = {"snake":40.0,"bird":86.0,"frog":54.0,"marmoset":110.0}[kind]
	if state == State.FORAGING and manager.can_react() and (player_distance < radius or mule_distance < radius):
		var threat = scene.player.global_position if player_distance < mule_distance else scene.mula.global_position
		start_flee(threat)
	if state == State.ALERT:
		velocity = Vector2.ZERO
		if state_time <= 0:
			state = State.FLEEING
			state_time = 2.2 if kind in ["bird","marmoset"] else 1.8
	elif state == State.FLEEING:
		var speed = {"snake":48.0,"bird":140.0,"frog":65.0,"marmoset":100.0}[kind]
		velocity = away*speed
		if kind == "frog": velocity *= 0.25+absf(sin(clock*12))*0.9
		move_and_slide()
		if get_slide_collision_count() > 0: away = away.rotated(0.65)
		if state_time <= 0:
			state = State.HIDDEN
			state_time = rng.randf_range(12,20)
			hide()
	else:
		# Small local motion: browsing, a cautious slither, or a stationary frog.
		if state_time <= 0:
			state_time = rng.randf_range(2,4)
			away = Vector2.from_angle(rng.randf_range(-PI,PI))
		var radius_home = 60 if kind == "bird" else 20
		var cruise_speed = 18 if kind == "bird" else 5
		velocity = away*cruise_speed if kind in ["snake","bird"] and global_position.distance_to(home)<radius_home else (home-global_position).limit_length(cruise_speed)
		move_and_slide()
	_update_visual()

func start_flee(threat: Vector2):
	if state != State.FORAGING: return
	away = (global_position-threat).normalized()
	if away.is_zero_approx(): away = Vector2.LEFT
	var to_cover = (cover-global_position).normalized()
	if to_cover.dot(away) > 0.2: away = to_cover
	if kind == "bird": away = (away+Vector2(0,-0.6)).normalized()
	state = State.ALERT
	state_time = 0.16
	flee_count += 1
	if kind in ["bird","frog"] and DisplayServer.get_name() != "headless": sound.play()

func _update_visual():
	var fleeing = state == State.FLEEING
	var frame = int(clock*(9 if fleeing else 5))%walk_frames.size() if kind == "bird" else (int(clock*6)%walk_frames.size() if kind == "snake" else 0)
	sprite.texture = walk_frames[frame]
	sprite.flip_h = away.x > 0
	var height = sprite.texture.get_height()*sprite.scale.y
	var lift = 0.0
	if kind == "bird" and fleeing: lift = 18+(2.2-state_time)*22
	elif kind == "bird": lift = 18+sin(clock*3)*2
	elif kind == "frog" and fleeing: lift = absf(sin(clock*12))*9
	elif kind == "marmoset": lift = 45+(absf(sin(clock*10))*16 if fleeing else sin(clock*2)*1.5)
	sprite.position.y = -height*0.5-lift
	shadow.modulate.a = 0.5 if lift>20 else 1.0
	modulate.a = clampf(state_time*3,0,1) if fleeing and state_time<0.33 else 1.0

func _exit_tree():
	if is_instance_valid(sound):
		sound.stop()
		sound.stream = null
