extends SceneTree

func _initialize():
	create_timer(15).timeout.connect(func(): quit(1))
	call_deferred("run")

func run():
	var frames = load("res://Assets/Sprites/Characters/hero_walk.tres") as SpriteFrames
	# A passing pose must have a visibly narrower silhouette than a contact pose.
	# Four near-identical drawings technically change frames but still look like sliding.
	for direction in [&"west",&"east"]:
		var narrow = INF
		var wide = 0.0
		for index in range(4):
			var bounds = frames.get_frame_texture(direction,index).get_image().get_used_rect()
			narrow = minf(narrow,bounds.size.x)
			wide = maxf(wide,bounds.size.x)
		if wide < narrow*1.22:
			push_error("Walk poses do not alternate stride and passing silhouettes: " + str(direction))
			quit(1)
			return
	var actor = CharacterBody2D.new()
	actor.set_script(load("res://Scripts/TropeiroPlayer.gd"))
	actor.collision_mask = 0
	var sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	actor.add_child(sprite)
	root.add_child(actor)
	var animator = actor.get_children().filter(func(node): return node.get_script() == load("res://Scripts/DirectionalAnimator.gd"))[0]
	for direction in [Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT,Vector2.UP]:
		actor.virtual_direction = direction
		var poses = {}
		for tick in range(50):
			await physics_frame
			poses[animator.previous_key] = true
		assert(poses.size() >= 4,"Movement must advance every walk pose")
	actor.virtual_direction = Vector2.ZERO
	for tick in range(12): await physics_frame
	var stopped = animator.previous_key
	for tick in range(12): await physics_frame
	assert(animator.previous_key == stopped,"Standing still must stop the walk cycle")
	actor.queue_free()
	await process_frame
	print("WALK_CYCLE_OK")
	quit()
