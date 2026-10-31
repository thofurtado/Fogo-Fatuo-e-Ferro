extends SceneTree
var scene
var snake
func _initialize():
	create_timer(30).timeout.connect(func(): quit(1))
	call_deferred("run")
func prepare():
	scene.player.global_position = Vector2(1200,1550)
	scene.player.velocity = Vector2.ZERO
	scene.damage_immunity = 0
	snake.global_position = Vector2(1230,1550)
	snake.state = snake.State.FORAGING
	snake.state_time = 5
	snake.attack_cooldown = 0
	snake.show()
func run():
	var gm = root.get_node("GameManager")
	gm.serra_save_enabled = false
	gm.select_archetype_by_id("tropeiro")
	scene = load("res://Scenes/SubidaSerra.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	for i in range(4): await physics_frame
	scene._dismiss_dialogue()
	scene.mula.global_position = Vector2(900,1300)
	scene.mula.set_physics_process(false)
	for animal in scene.wildlife.critters:
		animal.state = animal.State.HIDDEN
		animal.state_time = 999
		animal.hide()
	snake = scene.wildlife.critters.filter(func(a): return a.kind=="snake")[0]
	prepare()
	assert(snake.begin_strike())
	for i in range(30): await physics_frame
	assert(gm.current_archetype["vida_atual"]==24 and snake.state==snake.State.WINDUP,"Bite must have a visible warning window")
	for i in range(30): await physics_frame
	assert(gm.current_archetype["vida_atual"]==21,"Bite must deal exactly three damage")
	assert(not scene.receive_damage(3,"repeated hit"),"Brief invulnerability must reject repeated damage")
	assert(not snake.begin_strike(),"A held proximity must not bypass cooldown")
	prepare()
	assert(snake.begin_strike())
	scene.player.global_position = Vector2(1200,1450)
	for i in range(60): await physics_frame
	assert(gm.current_archetype["vida_atual"]==21,"Leaving the marked attack must dodge it")
	var wall = StaticBody2D.new()
	wall.position = Vector2(1215,1550)
	var shape_node = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(6,120)
	shape_node.shape = shape
	wall.add_child(shape_node)
	scene.add_child(wall)
	await physics_frame
	prepare()
	assert(snake.begin_strike())
	for i in range(60): await physics_frame
	assert(gm.current_archetype["vida_atual"]==21,"Bite must not pass through a wall")
	wall.queue_free()
	await physics_frame
	prepare()
	assert(snake.begin_strike())
	scene._toggle_inventory()
	for i in range(60): await physics_frame
	assert(gm.current_archetype["vida_atual"]==21,"Inventory must cancel an armed bite")
	scene._toggle_inventory()
	prepare()
	gm.current_archetype["vida_atual"] = 3
	assert(snake.begin_strike())
	for i in range(60): await physics_frame
	assert(gm.current_archetype["vida_atual"]==0 and scene.mission.finished and not scene.mission.won)
	assert(scene.mission.falls==0,"A bite must not be counted as a cliff fall")
	paused = false
	print("SNAKE_STRIKE_OK")
	scene.queue_free()
	await process_frame
	await process_frame
	quit()
