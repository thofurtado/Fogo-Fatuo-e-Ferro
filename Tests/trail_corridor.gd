extends SceneTree

func _initialize():
	create_timer(120).timeout.connect(func(): quit(1))
	call_deferred("run")

func run():
	root.get_node("GameManager").serra_save_enabled = false
	Engine.physics_ticks_per_second = 240
	Engine.time_scale = 5
	var scene = load("res://Scenes/SubidaSerra.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	for i in range(3): await physics_frame
	scene._dismiss_dialogue()
	var route: PackedVector2Array = scene.get_node("GroundLayer/MudTrailInner").points
	# Following the visible road must be safe in both directions. A shortest-path
	# test alone can miss a cliff trigger placed across the painted path.
	for backwards in [false,true]:
		var points = PackedVector2Array(route)
		if backwards: points.reverse()
		for point in points:
			var ticks = 0
			while scene.player.global_position.distance_to(point) > 5:
				scene.player.virtual_direction = (point-scene.player.global_position).normalized()
				await physics_frame
				ticks += 1
				if ticks > 1600 or scene.mission.falls > 0:
					push_error("Unsafe road at " + str(point) + " from " + str(scene.player.global_position))
					quit(1)
					return
		scene.player.virtual_direction = Vector2.ZERO
	print("TRAIL_CORRIDOR_OK · subida e descida sem quedas")
	# A deliberate shortcut still triggers one fall and lands outside the bank.
	scene.player.global_position = Vector2(975,1030)
	scene.mula.global_position = Vector2(900,1000)
	scene.player.virtual_direction = Vector2.DOWN
	var wait_ticks = 0
	while not scene.player.is_falling_ledge:
		await physics_frame
		wait_ticks += 1
		assert(wait_ticks < 180,"Shortcut must trigger a fall")
	scene.player.virtual_direction = Vector2.ZERO
	while scene.player.is_falling_ledge:
		await physics_frame
	await physics_frame
	assert(scene.mission.falls == 1,"A shortcut must cause exactly one fall")
	var feet = CircleShape2D.new()
	feet.radius = 14
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = feet
	query.exclude = [scene.player.get_rid(),scene.mula.get_rid()]
	query.collide_with_areas = false
	query.transform = Transform2D(0,scene.player.global_position+Vector2(0,4))
	assert(scene.get_world_2d().direct_space_state.intersect_shape(query,1).is_empty(),"Fall must land clear of the wall")
	print("BANK_LANDING_OK")
	scene.queue_free()
	await process_frame
	await process_frame
	quit()
