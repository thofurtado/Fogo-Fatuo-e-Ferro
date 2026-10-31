extends SceneTree
func _initialize():
	create_timer(35).timeout.connect(func(): quit(1))
	call_deferred("run")
func run():
	var gm = root.get_node("GameManager")
	gm.serra_save_enabled = false
	gm.select_archetype_by_id("tropeiro")
	var scene = load("res://Scenes/SubidaSerra.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	for i in range(4): await physics_frame
	scene._dismiss_dialogue()
	scene.wildlife.reactions_enabled = false
	var weather = scene.weather
	weather.set_weather(1,true)
	scene.player.global_position = Vector2(930,1440)
	scene.mula.global_position = Vector2(1040,1490)
	var life = gm.current_archetype["vida_atual"]
	for i in range(20): await physics_frame
	assert(not weather.sheltered and weather.rain==1)
	assert(scene.soundscape.loops.size()==7)
	for loop in scene.soundscape.loops.values(): assert(loop.stream.get_length()>0.1)
	assert(scene.soundscape.loops["rain_loop"].volume_db>scene.soundscape.loops["rain_roof"].volume_db)
	scene.player.virtual_direction = Vector2.UP
	var ticks = 0
	while scene.player.global_position.y>1348:
		await physics_frame
		ticks += 1
		assert(ticks<180,"Rancho entrance must be reachable")
	scene.player.virtual_direction = Vector2.ZERO
	for i in range(30): await physics_frame
	assert(weather.sheltered and scene.player.weather_speed_factor==1)
	assert(scene.get_node("YSortContainer/RanchoCabana/Sprite2D").modulate.a<0.8)
	assert(scene.soundscape.loops["rain_roof"].volume_db>scene.soundscape.loops["rain_loop"].volume_db)
	assert(gm.current_archetype["vida_atual"]==life,"Rain alone must not drain health")
	var before = weather.elapsed
	paused = true
	for i in range(5): await process_frame
	assert(weather.elapsed==before,"Weather must pause with the game")
	paused = false
	var bird = scene.wildlife.critters.filter(func(a): return a.kind=="bird")[0]
	var points = PackedVector2Array([Vector2(1100,1500),Vector2(1180,1500),Vector2(1280,1500)])
	var curve = Curve2D.new()
	for point in points: curve.add_point(point)
	bird.global_position = points[0]
	bird.configure_patrol(curve,points,PackedFloat32Array([0,1,0]))
	for i in range(150): await physics_frame
	assert(bird.weather_sheltering and bird.state==bird.State.FORAGING,"Heavy rain must keep the bird at its perch")
	weather.set_weather(0,true)
	for i in range(110): await physics_frame
	assert(not bird.weather_sheltering and bird.global_position.distance_to(points[1])>5,"Bird must resume flight after the rain")
	scene._toggle_inventory()
	scene._toggle_inventory()
	assert(scene.soundscape.cue_counts.get("inventory_click",0)==2)
	print("WEATHER_SOUND_OK")
	scene.queue_free()
	await process_frame
	await process_frame
	quit()
