extends Node2D
var fire_light: PointLight2D
var time: float = 0

func _ready():
	z_index = -5
	var scene = get_parent()
	var ground = scene.get_node("GroundLayer")
	var grain = ShaderMaterial.new()
	grain.shader = preload("res://Assets/Shaders/ground_detail.gdshader")
	for node in ground.get_children():
		if node is Polygon2D or node is ColorRect or node.name in ["MudTrailBase","MudTrailInner"]:
			node.material = grain
		if node is Polygon2D and node.name != "OceanEstuary":
			var transition = ShaderMaterial.new()
			transition.shader = preload("res://Assets/Shaders/terrain_transition.gdshader")
			var edges = PackedVector2Array(node.polygon)
			var count = edges.size()
			edges.resize(32)
			transition.set_shader_parameter("edge_points", edges)
			transition.set_shader_parameter("edge_count", count)
			transition.set_shader_parameter("feather", 30.0 if node.name == "SantosGround" else 22.0)
			node.material = transition
	var trail_material = ShaderMaterial.new()
	trail_material.shader = preload("res://Assets/Shaders/trail_surface.gdshader")
	var trail_points = PackedVector2Array(ground.get_node("MudTrailBase").points)
	trail_material.set_shader_parameter("point_count",trail_points.size())
	trail_points.resize(40)
	trail_material.set_shader_parameter("path_points",trail_points)
	ground.get_node("MudTrailBase").material = trail_material
	ground.get_node("MudTrailInner").hide()
	var water = ShaderMaterial.new()
	water.shader = preload("res://Assets/Shaders/river_surface.gdshader")
	for name in ["OceanEstuary","RioCubatao","CachoeiraVeu"]:
		ground.get_node(NodePath(name)).material = water
	# A narrow earth bank ties the water to the land instead of a hard blue cutout.
	var river_bank = Line2D.new()
	river_bank.points = ground.get_node("RioCubatao").points
	river_bank.width = 54
	river_bank.default_color = Color(0.33,0.36,0.23)
	river_bank.joint_mode = Line2D.LINE_JOINT_ROUND
	river_bank.begin_cap_mode = Line2D.LINE_CAP_ROUND
	river_bank.end_cap_mode = Line2D.LINE_CAP_ROUND
	ground.add_child(river_bank)
	ground.move_child(river_bank, ground.get_node("RioCubatao").get_index())
	var coast = ground.get_node("OceanEstuary").polygon
	var shore = Line2D.new()
	var shore_points = PackedVector2Array()
	for segment in range(5):
		var steps = ceili(coast[segment].distance_to(coast[segment+1])/12.0)
		for step in range(steps):
			var point = coast[segment].lerp(coast[segment+1],float(step)/steps)
			point.y += sin(point.x*0.071)*1.8 + sin(point.x*0.19)*0.7
			shore_points.append(point)
	shore_points.append(coast[5])
	shore.points = shore_points
	shore.width = 8
	shore.default_color = Color(0.42,0.43,0.28)
	shore.joint_mode = Line2D.LINE_JOINT_ROUND
	shore.material = grain
	ground.add_child(shore)
	ground.move_child(shore, ground.get_node("OceanEstuary").get_index()+1)
	# Use the same timber as the port for the crossing, retaining its collision area.
	var bridge = Sprite2D.new()
	bridge.texture = preload("res://Assets/Sprites/Clean/pier.png")
	bridge.position = Vector2(824,1420)
	bridge.scale = Vector2(0.105,0.044)
	ground.get_node("RiverBridge").color.a = 0
	ground.add_child(bridge)
	var motes = preload("res://Scripts/ForestMotes.gd").new()
	motes.player = scene.player
	motes.z_index = 25
	scene.add_child.call_deferred(motes)
	for actor in scene.get_node("YSortContainer").get_children():
		var sprite = actor.get_node_or_null("Sprite2D") as Sprite2D
		if sprite:
			var shadow = preload("res://Scripts/GroundShadow.gd").new()
			var companion = actor == scene.player or actor == scene.mula
			shadow.width = (12.0 if actor == scene.player else 16.0) if companion else minf(65, sprite.get_rect().size.x * sprite.scale.x * 0.34)
			if not companion:
				shadow.position = Vector2(sprite.position.x, sprite.position.y + sprite.get_rect().end.y * sprite.scale.y - 2)
				shadow.depth = 0.18
			shadow.z_index = -1
			actor.add_child(shadow)
			if actor == scene.player or actor == scene.mula:
				var dust = CPUParticles2D.new()
				dust.name = "FootstepDust"
				dust.amount = 10
				dust.lifetime = 0.45
				dust.direction = Vector2(0,-1)
				dust.gravity = Vector2(0,-4)
				dust.initial_velocity_min = 3
				dust.initial_velocity_max = 10
				dust.spread = 70
				dust.scale_amount_min = 1
				dust.scale_amount_max = 2
				dust.color = Color(0.65,0.52,0.32,0.25)
				dust.emitting = false
				actor.add_child(dust)
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color.WHITE, Color(1,1,1,0)])
	var glow = GradientTexture2D.new()
	glow.gradient = gradient
	glow.width = 256
	glow.height = 256
	glow.fill = GradientTexture2D.FILL_RADIAL
	glow.fill_from = Vector2(0.5,0.5)
	glow.fill_to = Vector2(1,0.5)
	fire_light = PointLight2D.new()
	fire_light.texture = glow
	fire_light.color = Color(1,0.65,0.28)
	fire_light.position = scene.get_node("YSortContainer/RanchoFogueira").global_position
	fire_light.energy = 0.65
	add_child(fire_light)
	var ambience = AudioStreamPlayer.new()
	ambience.stream = load("res://Assets/SFX/forest_ambience.wav")
	if ambience.stream is AudioStreamWAV:
		ambience.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	ambience.volume_db = -16
	add_child(ambience)
	if DisplayServer.get_name() != "headless":
		ambience.play()

func _process(delta):
	time += delta
	if fire_light:
		fire_light.energy = 0.65 + sin(time*7.1)*0.06 + sin(time*11.7)*0.04
	var scene = get_parent()
	for actor in [scene.player,scene.mula]:
		var dust = actor.get_node_or_null("FootstepDust")
		if dust:
			dust.emitting = actor.is_moving and not actor.in_water and not actor.is_falling_ledge

func _draw():
	var scene = get_parent()
	var trail: PackedVector2Array = scene.get_node("GroundLayer/MudTrailInner").points
	var rng = RandomNumberGenerator.new()
	rng.seed = 1645
	var coast = scene.get_node("GroundLayer/OceanEstuary").polygon
	var port = scene.get_node("GroundLayer/SantosGround").polygon
	for i in range(1800):
		var point = Vector2(rng.randf_range(16,1700), rng.randf_range(16,2220))
		if Geometry2D.is_point_in_polygon(point,coast) or Geometry2D.is_point_in_polygon(point,port):
			continue
		var near_trail = false
		for j in range(trail.size()-1):
			if point.distance_to(Geometry2D.get_closest_point_to_segment(point,trail[j],trail[j+1])) < 40:
				near_trail = true
				break
		if near_trail:
			continue
		var tint = Color(0.33+rng.randf()*0.10,0.54+rng.randf()*0.12,0.25,0.52)
		var size = rng.randf_range(2,5)
		draw_line(point,point+Vector2(-2,-size),tint,1,true)
		draw_line(point,point+Vector2(1,-size-1),tint,1,true)
		if i%19 == 0:
			draw_circle(point+Vector2(1,-size),1.3,Color(0.9,0.78,0.39,0.65))

func _exit_tree():
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null
