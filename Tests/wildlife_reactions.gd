extends SceneTree

func _initialize():
	create_timer(25).timeout.connect(func(): quit(1))
	call_deferred("run")

func run():
	var gm = root.get_node("GameManager")
	gm.serra_save_enabled = false
	var scene = load("res://Scenes/SubidaSerra.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	for i in range(4): await physics_frame
	scene._dismiss_dialogue()
	var wildlife = scene.wildlife
	assert(wildlife.critters.size() == 12)
	for animal in wildlife.critters:
		animal.state = animal.State.HIDDEN
		animal.state_time = 999
		animal.hide()
	for kind in ["bird","frog","marmoset"]:
		var animal = wildlife.critters.filter(func(a): return a.kind == kind)[0]
		animal.global_position = Vector2(1200,1550)
		animal.state = animal.State.FORAGING
		animal.state_time = 2
		animal.show()
		scene.player.global_position = Vector2(1160,1550)
		scene.mula.global_position = Vector2(1100,1550)
		for i in range(30): await physics_frame
		assert(animal.flee_count == 1,"Approach must trigger one escape: "+kind)
		assert(animal.global_position.distance_to(Vector2(1200,1550)) > 5,"Animal must actually move: "+kind)
		animal.state = animal.State.HIDDEN
		animal.state_time = 999
		animal.hide()
	var snake = wildlife.critters.filter(func(a): return a.kind == "snake")[0]
	snake.global_position = Vector2(1230,1585)
	snake.state = snake.State.FORAGING
	snake.state_time = 2
	snake.show()
	scene.player.global_position = Vector2(1200,1550)
	scene.mula.global_position = Vector2(1230,1550)
	scene.mula.breadcrumbs.clear()
	var player_before = scene.player.global_position
	var affinity_before = scene.mula.affinity
	for i in range(90): await physics_frame
	assert(scene.mula.panic_count == 1,"Snake must startle the mule once")
	assert(scene.player.global_position.distance_to(player_before) > 5,"Taut rein must pull the player through physics")
	assert(scene.player.global_position.distance_to(player_before) < 100,"Rein pull must stay bounded rather than accumulate acceleration")
	assert(scene.mula.panic_time == 0,"Mule must recover from fear")
	assert(not scene.mula.startle(snake.global_position),"Cooldown must prevent repeated scares")
	assert(scene.mula.affinity == affinity_before,"A scare must not repeatedly deduct affinity")
	scene.mula.panic_cooldown = 0
	scene.player.input_blocked = true
	assert(not scene.mula.startle(snake.global_position),"Inventory must suppress a scare")
	scene.player.input_blocked = false
	paused = true
	assert(not scene.mula.startle(snake.global_position),"Pause must suppress a scare")
	paused = false
	wildlife.enabled = false
	scene.player.global_position = Vector2(1200,1550)
	scene.player.leash_time = 0
	scene.player.velocity = Vector2.ZERO
	var wall = StaticBody2D.new()
	wall.position = Vector2(1235,1550)
	var wall_shape = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	rectangle.size = Vector2(12,100)
	wall_shape.shape = rectangle
	wall.add_child(wall_shape)
	scene.add_child(wall)
	await physics_frame
	scene.player.apply_leash_pull(Vector2(75,0),0.6)
	for i in range(50): await physics_frame
	assert(scene.player.global_position.x <= 1216,"Rein pull must not cross a solid wall")
	print("WILDLIFE_REACTIONS_OK")
	scene.queue_free()
	await process_frame
	await process_frame
	quit()
