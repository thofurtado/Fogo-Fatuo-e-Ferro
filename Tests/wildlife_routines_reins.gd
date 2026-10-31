extends SceneTree

func _initialize():
	create_timer(90).timeout.connect(func(): quit(1))
	call_deferred("run")

func run():
	root.get_node("GameManager").serra_save_enabled = false
	Engine.physics_ticks_per_second = 240
	Engine.time_scale = 6
	var scene = load("res://Scenes/SubidaSerra.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	for i in range(4): await physics_frame
	scene._dismiss_dialogue()
	scene.wildlife.reactions_enabled = false
	var poses = {}
	var concealed_seen = false
	var idle_seen = false
	for tick in range(ceili(40.0*Engine.physics_ticks_per_second/Engine.time_scale)):
		await physics_frame
		for animal in scene.wildlife.critters:
			assert(animal.blocked_time < 2,"Route blocked: "+animal.name)
			if animal.is_concealed(): concealed_seen = true
			if animal.kind == "marmoset" and animal.state == animal.State.FORAGING:
				idle_seen = true
				poses[animal.sprite.texture.get_instance_id()] = true
				assert(animal.visual_lift > 100,"Marmoset must stay in the canopy")
			if animal.kind == "bird":
				assert(animal.get_parent() == scene.wildlife.sky_layer,"Birds must use the sky layer")
	for animal in scene.wildlife.critters:
		assert(animal.waypoints_visited >= 2,"Route does not progress: "+animal.name)
	assert(concealed_seen and idle_seen and poses.size() >= 2,"Shelter and visible idle poses must occur")
	scene.wildlife.enabled = false
	scene.player.set_physics_process(false)
	scene.mula.set_physics_process(false)
	scene.player.global_position = Vector2(1200,1550)
	scene.mula.global_position = Vector2(1200,1590)
	var rope = scene.mula.rein_line
	rope.update_rope()
	assert(rope.points.size() == 25)
	assert(rope.to_global(rope.points[0]).distance_to(scene.mula.get_rein_anchor())<0.1,"Rein must attach to the halter")
	assert(rope.to_global(rope.points[-1]).distance_to(scene.player.get_rein_anchor())<0.1,"Rein must attach to the hand")
	var middle = rope.points[0].lerp(rope.points[-1],0.5)
	assert(rope.points[12].y-middle.y > 8,"A loose rein must sag")
	scene.mula.global_position = Vector2(1200,1680)
	rope.update_rope()
	middle = rope.points[0].lerp(rope.points[-1],0.5)
	assert(rope.tension > 0.95 and rope.points[12].y-middle.y < 2,"A taut rein must straighten")
	for direction in [&"north",&"south",&"west",&"east"]:
		scene.player.directional_animator.direction = direction
		scene.mula.directional_animator.direction = direction
		scene.player.directional_animator._apply_frame(0)
		scene.mula.directional_animator._apply_frame(0)
		rope.update_rope()
		for point in rope.points: assert(point.is_finite(),"Turning must not corrupt the rein")
	print("WILDLIFE_ROUTINES_REINS_OK")
	scene.queue_free()
	await process_frame
	await process_frame
	quit()
