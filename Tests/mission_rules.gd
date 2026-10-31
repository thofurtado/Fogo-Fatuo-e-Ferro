extends SceneTree

var gm: Node
func _initialize():
	create_timer(20).timeout.connect(func(): quit(1))
	call_deferred("run")
func run():
	gm = root.get_node("GameManager")
	gm.serra_save_path = "user://serra-mission-test.json"
	gm.select_archetype_by_id("tropeiro")
	gm.select_cargo("sal_charque")
	var scene = load("res://Scenes/SubidaSerra.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await process_frame
	scene.current_interactable = {"id":"altar_caipora"}
	scene._dismiss_dialogue()
	scene._handle_interaction()
	assert(not scene.caipora_offering_done, "Oferenda não pode surgir sem item")
	scene.current_interactable = {"id":"cruzeiro_topo"}
	scene._dismiss_dialogue()
	scene._handle_interaction()
	assert(not scene.mission.finished, "Missão não pode terminar sem preparativos")
	scene.current_interactable = {"id":"bau_rancho"}
	scene._dismiss_dialogue()
	scene._handle_interaction()
	assert(scene.chest_opened and gm.inventory.has(scene.OFFERING_ITEM))
	gm.current_archetype["vida_atual"] = gm.current_archetype["vida_max"] - 8
	scene._use_provision()
	assert(gm.current_archetype["vida_atual"] == gm.current_archetype["vida_max"] - 2)
	assert(not gm.inventory.has(scene.FOOD_ITEM), "Comida deve ser consumida")
	scene.current_interactable = {"id":"fogueira_rancho"}
	scene._dismiss_dialogue()
	scene._handle_interaction()
	var affinity = scene.mula.affinity
	scene._dismiss_dialogue()
	scene._handle_interaction()
	assert(scene.mula.affinity == affinity, "Repouso repetido não multiplica recompensa")
	scene.current_interactable = {"id":"altar_caipora"}
	scene._dismiss_dialogue()
	scene._handle_interaction()
	assert(scene.caipora_offering_done and not gm.inventory.has(scene.OFFERING_ITEM))
	var saved = gm.read_serra_checkpoint()
	assert(saved.get("chest") and saved.get("rested") and saved.get("offering"))
	scene.caipora_offering_done = false
	scene.mission._restore(saved)
	assert(scene.caipora_offering_done, "Checkpoint deve restaurar etapa")
	scene.mission.complete()
	assert(scene.mission.won and paused and scene.mission.result_panel.visible)
	assert(gm.read_serra_checkpoint().is_empty(), "Vitória deve encerrar checkpoint")
	paused = false
	scene.queue_free()
	await process_frame
	gm.select_archetype_by_id("tropeiro")
	scene = load("res://Scenes/SubidaSerra.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await process_frame
	scene.current_interactable = {"id":"bau_rancho"}
	scene._dismiss_dialogue()
	scene._handle_interaction()
	gm.current_archetype["vida_atual"] = 0
	scene.mission.register_fall()
	assert(scene.mission.finished and not scene.mission.won and paused)
	scene.mission._retry()
	for i in range(4):
		await process_frame
	assert(not paused and current_scene.chest_opened, "Retomar deve carregar checkpoint")
	assert(gm.current_archetype["vida_atual"] == gm.current_archetype["vida_max"])
	gm.clear_serra_checkpoint()
	print("MISSION_RULES_OK")
	if current_scene:
		current_scene.queue_free()
	await process_frame
	await process_frame
	call_deferred("quit")
