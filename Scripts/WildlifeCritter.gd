extends CharacterBody2D

enum State { FORAGING, ALERT, FLEEING, HIDDEN, PATROLLING, WINDUP, STRIKING, RECOVERING }
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
var idle_frames: Array[Texture2D] = []
var patrol_curve: Curve2D
var patrol_points: PackedVector2Array
var pause_times: PackedFloat32Array
var sheltered_stops: PackedInt32Array
var perch_height: float = 0
var patrol_speed: float = 25
var waypoint_index: int = 1
var stop_index: int = 0
var waypoints_visited: int = 0
var idle_visits: int = 0
var route_progress: float = 0
var leg_start: float = 0
var stop_offsets: PackedFloat32Array
var visual_lift: float = 0
var blocked_time: float = 0
var flee_target: Vector2
var attack_cooldown: float = 0
var attack_origin: Vector2
var strike_goal: Vector2
var attack_hit: bool = false
var weather_sheltering: bool = false
var call_time: float = 5

func _ready():
	home = global_position
	rng.seed = int(home.x*11+home.y)
	clock = rng.randf_range(0,10)
	collision_layer = 0
	collision_mask = 0 if kind in ["bird","marmoset"] else 1
	if kind == "marmoset": z_index = 2
	var shape_node = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 3
	shape_node.shape = shape
	add_child(shape_node)
	sprite = Sprite2D.new()
	add_child(sprite)
	match kind:
		"snake": walk_frames = [preload("res://Assets/Sprites/Fauna/snake_0.tres"),preload("res://Assets/Sprites/Fauna/snake_1.tres")]
		"bird":
			walk_frames = [preload("res://Assets/Sprites/Fauna/bird_0.tres"),preload("res://Assets/Sprites/Fauna/bird_1.tres")]
			idle_frames = [preload("res://Assets/Sprites/Fauna/bird_idle_0.tres"),preload("res://Assets/Sprites/Fauna/bird_idle_1.tres")]
		"frog": walk_frames = [preload("res://Assets/Sprites/Fauna/frog.tres")]
		"marmoset":
			walk_frames = [preload("res://Assets/Sprites/Fauna/marmoset.tres")]
			idle_frames = [preload("res://Assets/Sprites/Fauna/marmoset_idle_0.tres"),preload("res://Assets/Sprites/Fauna/marmoset_idle_1.tres")]
	if idle_frames.is_empty(): idle_frames = walk_frames
	shadow = preload("res://Scripts/GroundShadow.gd").new()
	shadow.width = 7 if kind != "frog" else 4
	shadow.z_as_relative = false
	shadow.z_index = -4
	add_child(shadow)
	sound = AudioStreamPlayer2D.new()
	sound.stream = preload("res://Assets/SFX/wildlife_flutter.wav") if kind == "bird" else preload("res://Assets/SFX/wildlife_frog.wav")
	sound.volume_db = -24 if kind == "bird" else -28
	sound.max_distance = 300
	add_child(sound)
	configure_patrol(patrol_curve,patrol_points,pause_times)
	visual_lift = perch_height
	_update_visual(0)

func configure_patrol(curve: Curve2D, points: PackedVector2Array, pauses: PackedFloat32Array):
	patrol_curve = curve
	patrol_points = points
	pause_times = pauses
	stop_offsets.clear()
	for index in range(points.size()):
		var offset = curve.get_closest_offset(points[index])
		if index == points.size()-1: offset = curve.get_baked_length()
		stop_offsets.append(offset)
	route_progress = 0
	leg_start = 0
	waypoint_index = 1
	stop_index = 0
	state_time = pause_times[0] if not pause_times.is_empty() else 2.0
	state = State.FORAGING if state_time > 0 else State.PATROLLING
	idle_visits = 1 if state == State.FORAGING else 0

func is_concealed() -> bool:
	return kind == "snake" and state == State.FORAGING and sheltered_stops.has(stop_index) and global_position.distance_to(patrol_points[stop_index]) < 12

func _physics_process(delta):
	if not manager.enabled: return
	clock += delta
	state_time -= delta
	attack_cooldown = maxf(0,attack_cooldown-delta)
	var scene = manager.scene
	var wet = scene.weather.rain if scene.weather else 0.0
	if state == State.HIDDEN:
		if state_time <= 0 and home.distance_to(scene.player.global_position) > 160 and home.distance_to(scene.mula.global_position) > 160 and not manager.is_position_visible(home,perch_height):
			global_position = home
			configure_patrol(patrol_curve,patrol_points,pause_times)
			modulate.a = 1
			show()
		return
	if kind == "snake": manager.snake_near(self)
	var player_distance = global_position.distance_to(scene.player.global_position)
	var mule_distance = global_position.distance_to(scene.mula.global_position)
	var radius = {"snake":40.0,"bird":86.0,"frog":54.0,"marmoset":110.0}[kind]
	if is_concealed(): radius = 22
	if kind == "snake" and state in [State.FORAGING,State.PATROLLING] and player_distance<40 and not is_concealed() and attack_cooldown<=0 and manager.can_react():
		begin_strike()
	if state in [State.WINDUP,State.STRIKING,State.RECOVERING]:
		_update_strike(delta)
		_update_visual(delta)
		queue_redraw()
		return
	weather_sheltering = wet>0.6 and kind in ["bird","marmoset"]
	if weather_sheltering and kind == "bird" and state == State.PATROLLING:
		for index in range(1,pause_times.size()-1):
			if pause_times[index]>0:
				waypoint_index = index
				break
	if state in [State.FORAGING,State.PATROLLING] and manager.can_react() and (player_distance < radius or mule_distance < radius):
		start_flee(scene.player.global_position if player_distance < mule_distance else scene.mula.global_position)
	match state:
		State.ALERT:
			velocity = Vector2.ZERO
			if state_time <= 0:
				state = State.FLEEING
				state_time = 2.2 if kind in ["bird","marmoset"] else 1.8
		State.FLEEING: _flee(delta)
		State.PATROLLING: _walk_route(delta)
		State.FORAGING:
			velocity = Vector2.ZERO
			if weather_sheltering: state_time = maxf(state_time,1.0)
			if kind == "frog":
				state_time -= delta*wet*0.6
				call_time -= delta
				if call_time<=0 and wet>0.2:
					call_time = rng.randf_range(5,9)
					if DisplayServer.get_name() != "headless": sound.play()
			if state_time <= 0: state = State.PATROLLING
	_update_visual(delta)
	queue_redraw()

func _walk_route(delta):
	if patrol_points.size() < 2: return
	var goal = stop_offsets[waypoint_index]
	var speed = patrol_speed
	if kind == "frog" and manager.scene.weather: speed *= 1.0+manager.scene.weather.rain*0.45
	if kind == "frog": speed *= 0.25+absf(sin(clock*10))*0.9
	var next_progress = minf(goal,route_progress+speed*delta)
	var desired = patrol_curve.sample_baked(next_progress,true)
	var before = global_position
	velocity = ((desired-global_position)/maxf(delta,0.001)).limit_length(speed*1.2)
	if velocity.length() > 0.1: away = velocity.normalized()
	move_and_slide()
	if global_position.distance_to(desired) < 2: route_progress = next_progress
	blocked_time = blocked_time+delta if global_position.distance_to(before)<0.005 else 0
	if route_progress >= goal-0.1 and global_position.distance_to(patrol_points[waypoint_index])<3:
		_arrive()

func _arrive():
	stop_index = waypoint_index
	waypoints_visited += 1
	velocity = Vector2.ZERO
	if waypoint_index == patrol_points.size()-1:
		if kind == "bird":
			_hide_for_a_while()
			return
		route_progress = 0
		stop_index = 0
		waypoint_index = 1
	else:
		waypoint_index += 1
	leg_start = route_progress
	state_time = pause_times[stop_index] if stop_index<pause_times.size() else 3.0
	state = State.FORAGING if state_time > 0 else State.PATROLLING
	if state == State.FORAGING: idle_visits += 1

func start_flee(threat: Vector2):
	if state not in [State.FORAGING,State.PATROLLING]: return
	away = (global_position-threat).normalized()
	if away.is_zero_approx(): away = Vector2.LEFT
	var to_cover = (cover-global_position).normalized()
	if to_cover.dot(away) > 0.2: away = to_cover
	if kind == "bird": away = (away+Vector2(0,-0.6)).normalized()
	if kind == "marmoset":
		# Retreat to another branch of the same tree, never run across the sky.
		flee_target = patrol_points[0]
		for point in patrol_points:
			if point.distance_squared_to(threat)>flee_target.distance_squared_to(threat): flee_target = point
	state = State.ALERT
	state_time = 0.16
	flee_count += 1
	if kind in ["bird","frog"] and DisplayServer.get_name() != "headless": sound.play()

func _flee(delta):
	var speed = {"snake":48.0,"bird":140.0,"frog":65.0,"marmoset":100.0}[kind]
	if kind == "marmoset":
		var remaining = flee_target-global_position
		away = remaining.normalized() if remaining.length()>2 else away
		velocity = remaining.limit_length(speed*delta)/maxf(delta,0.001)
		if remaining.length()<3: state_time = minf(state_time,0.3)
	else:
		velocity = away*speed
		if kind == "frog": velocity *= 0.25+absf(sin(clock*12))*0.9
	move_and_slide()
	if get_slide_collision_count() > 0: away = away.rotated(0.65)
	if state_time <= 0: _hide_for_a_while()

func _hide_for_a_while():
	state = State.HIDDEN
	state_time = rng.randf_range(12,20)
	hide()

func begin_strike() -> bool:
	if kind != "snake" or state not in [State.FORAGING,State.PATROLLING] or attack_cooldown>0 or not manager.can_react() or is_concealed(): return false
	attack_origin = global_position
	var target = manager.scene.player.global_position
	strike_goal = global_position+(target-global_position).limit_length(36)
	away = (target-global_position).normalized()
	attack_hit = false
	attack_cooldown = 6.0
	state = State.WINDUP
	state_time = 0.7
	velocity = Vector2.ZERO
	manager.scene.soundscape.play_cue("snake_hiss",-15)
	manager.scene.mission.notify("Jararaca armou o bote! Afaste-se.",Color(1,0.78,0.30))
	return true

func _update_strike(delta):
	if not manager.can_react() and state != State.RECOVERING:
		state = State.RECOVERING
		state_time = 0.6
		attack_hit = true
	match state:
		State.WINDUP:
			velocity = Vector2.ZERO
			if state_time<=0:
				state = State.STRIKING
				state_time = 0.18
		State.STRIKING:
			velocity = ((strike_goal-global_position)/maxf(delta,0.001)).limit_length(220)
			move_and_slide()
			var player = manager.scene.player
			if not attack_hit and global_position.distance_to(player.global_position)<22:
				var ray = PhysicsRayQueryParameters2D.create(global_position,player.global_position,1,[get_rid(),player.get_rid(),manager.scene.mula.get_rid()])
				if get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
					attack_hit = manager.scene.receive_damage(3,"Picada de jararaca")
			if state_time<=0:
				state = State.RECOVERING
				state_time = 0.6
		State.RECOVERING:
			velocity = ((attack_origin-global_position)/maxf(delta,0.001)).limit_length(60)
			move_and_slide()
			if state_time<=0:
				state = State.PATROLLING
				velocity = Vector2.ZERO

func _draw():
	if state != State.WINDUP: return
	var pulse = 0.35+absf(sin(clock*10))*0.30
	draw_arc(Vector2.ZERO,24,0,TAU,32,Color(1,0.65,0.15,pulse),1.8,true)
	draw_line(Vector2.ZERO,away*30,Color(1,0.65,0.15,pulse),2,true)

func _update_visual(delta):
	var moving = state in [State.PATROLLING,State.FLEEING,State.STRIKING] and velocity.length()>0.1
	var idle = state == State.FORAGING
	var poses = idle_frames if idle else walk_frames
	var rate = (1.2 if kind == "marmoset" else 0.65) if idle else (9.0 if kind == "bird" else 6.0)
	sprite.texture = poses[int(clock*rate)%poses.size()]
	var width = {"snake":34.0,"bird":38.0,"frog":17.0,"marmoset":41.0}[kind]
	var scale_base = width/sprite.texture.get_width()
	if idle and kind == "marmoset": scale_base = minf(scale_base,32.0/sprite.texture.get_height())
	var breath = sin(clock*2.8)*0.016 if idle else 0.0
	sprite.scale = Vector2(scale_base,scale_base*(1+breath))
	sprite.flip_h = away.x > 0
	sprite.rotation = 0
	var target_lift = perch_height if kind == "marmoset" or (kind == "bird" and idle) else 0.0
	if kind == "bird" and not idle: target_lift = 90.0 if state != State.FLEEING else 120.0
	visual_lift = move_toward(visual_lift,target_lift,delta*100)
	var lift = visual_lift
	if moving and kind == "frog": lift += absf(sin(clock*10))*8
	if moving and kind == "marmoset":
		var leg_length = maxf(1,stop_offsets[waypoint_index]-leg_start)
		var progress = clampf((route_progress-leg_start)/leg_length,0,1)
		lift += sin(progress*PI)*18 if state == State.PATROLLING else absf(sin(clock*8))*12
	var height = sprite.texture.get_height()*sprite.scale.y
	sprite.position.y = -height*0.5-lift
	if kind == "snake":
		sprite.position.y = -3
		if moving: sprite.rotation = away.angle()-(0 if sprite.flip_h else PI)
		if state == State.WINDUP: sprite.scale *= Vector2(0.88,1.25)
	shadow.modulate.a = 0.3 if lift>20 else 1.0
	modulate.a = clampf(state_time*3,0,1) if state == State.FLEEING and state_time<0.33 else 1.0

func _exit_tree():
	if is_instance_valid(sound):
		sound.stop()
		sound.stream = null
