extends SceneTree
func _initialize():
	create_timer(60).timeout.connect(func(): quit(1))
	call_deferred("run")
func run():
	root.get_node("GameManager").serra_save_enabled = false
	Engine.physics_ticks_per_second = 300
	Engine.time_scale = 5
	var scene = load("res://Scenes/SubidaSerra.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await physics_frame
	await physics_frame
	var grid = AStarGrid2D.new()
	grid.region = Rect2i(0,0,108,140)
	grid.cell_size = Vector2(16,16)
	grid.offset = Vector2(8,8)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	var shape = CircleShape2D.new()
	shape.radius = 15
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collide_with_areas = false
	query.exclude = [scene.player.get_rid(), scene.mula.get_rid()]
	var space = scene.get_world_2d().direct_space_state
	query.transform = Transform2D(0,Vector2(1005,2030))
	assert(space.intersect_shape(query,1).is_empty(), "The pier deck must be walkable")
	query.transform = Transform2D(0,Vector2(1075,2030))
	assert(not space.intersect_shape(query,1).is_empty(), "Water beside the pier must remain blocked")
	for y in range(140):
		for x in range(108):
			query.transform = Transform2D(0,Vector2(x*16+8,y*16+8))
			grid.set_point_solid(Vector2i(x,y), not space.intersect_shape(query,1).is_empty())
	var previous = Vector2i(scene.player.global_position / 16)
	var interactions = {"RanchoBau":"bau_rancho","RanchoFogueira":"fogueira_rancho","AltarCaipora":"altar_caipora","CruzeiroTopo":"cruzeiro_topo"}
	for name in ["RanchoBau","RanchoFogueira","AltarCaipora","CruzeiroTopo"]:
		var target = scene.get_node("YSortContainer/"+name).global_position
		var goal = Vector2i(target / 16)
		var path: Array[Vector2i] = []
		for offset_y in range(-3,4):
			for offset_x in range(-3,4):
				var candidate = goal + Vector2i(offset_x,offset_y)
				if not grid.region.has_point(candidate) or grid.is_point_solid(candidate):
					continue
				if grid.get_point_position(candidate).distance_to(target) > 44:
					continue
				var route = grid.get_id_path(previous,candidate)
				if not route.is_empty() and (path.is_empty() or route.size()<path.size()):
					path = route
		print("ROUTE ",name," points=",path.size())
		assert(not path.is_empty(), "Objetivo sem caminho acessível: " + name)
		for cell in path:
			var point = grid.get_point_position(cell)
			var ticks = 0
			while scene.player.global_position.distance_to(point) > 5 and scene.player.global_position.distance_to(target) > 44:
				scene.player.virtual_direction = (point - scene.player.global_position).normalized()
				await physics_frame
				ticks += 1
				assert(ticks < 300, "Personagem preso no percurso: " + name + " em " + str(scene.player.global_position))
				assert(not scene.mission.finished, "Comitiva falhou durante o percurso")
			if scene.player.global_position.distance_to(target) <= 44:
				break
		scene.player.virtual_direction = Vector2.ZERO
		await physics_frame
		await physics_frame
		assert(scene.current_interactable and scene.current_interactable["id"] == interactions[name], "Alvo não alcançável pela área: " + name)
		scene._dismiss_dialogue()
		scene._handle_screen_interaction()
		previous = Vector2i(scene.player.global_position / 16)
	assert(scene.mission.won, "Percurso deve terminar em entrega concluída")
	print("MISSION_ROUTE_OK · falls=", scene.mission.falls)
	paused = false
	if current_scene:
		current_scene.queue_free()
	await process_frame
	await process_frame
	call_deferred("quit")
