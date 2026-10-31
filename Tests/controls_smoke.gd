extends SceneTree

# Run with: godot --headless --path . --script res://Tests/controls_smoke.gd
func _initialize() -> void:
	create_timer(15).timeout.connect(func(): quit(1))
	call_deferred("_run")

func _run() -> void:
	root.get_node("GameManager").serra_save_enabled = false
	var scene = load("res://Scenes/SubidaSerra.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var player = scene.get_node("YSortContainer/Player")
	var mula = scene.get_node("YSortContainer/MulaBonita")
	scene._dismiss_dialogue()
	scene.current_interactable = {"id": "fogueira_rancho"}
	var initial_affinity: int = mula.affinity
	var interaction = InputEventKey.new()
	interaction.physical_keycode = KEY_E
	interaction.pressed = true
	scene._unhandled_input(interaction)
	await process_frame
	await process_frame
	assert(mula.affinity == initial_affinity + 15, "Interação deve acontecer uma vez")
	interaction.echo = true
	scene._unhandled_input(interaction)
	assert(mula.affinity == initial_affinity + 15, "Repetição de tecla não deve interagir")
	var inventory = InputEventJoypadButton.new()
	inventory.button_index = JOY_BUTTON_Y
	inventory.pressed = true
	scene._unhandled_input(inventory)
	assert(scene.inventory_panel.visible and player.input_blocked, "Y deve abrir e bloquear movimento")
	var cancel = InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	scene._unhandled_input(cancel)
	assert(not scene.inventory_panel.visible and not player.input_blocked, "Cancelar deve fechar inventário")
	var controls = scene.get_node("UILayer").get_children().back()
	assert(controls.get_child_count() == 6, "Controles visíveis ausentes")
	var right = controls.get_child(3)
	right.emit_signal("button_down")
	assert(player.virtual_direction == Vector2.RIGHT, "Pressionar direção deve mover")
	right.emit_signal("button_up")
	assert(player.virtual_direction == Vector2.ZERO, "Soltar direção deve parar")
	var touch_move = InputEventScreenTouch.new()
	touch_move.index = 0
	touch_move.position = right.get_global_rect().get_center()
	touch_move.pressed = true
	scene._input(touch_move)
	assert(player.virtual_direction == Vector2.RIGHT, "Toque deve mover")
	var touch_action = InputEventScreenTouch.new()
	touch_action.index = 1
	touch_action.position = controls.get_child(4).get_global_rect().get_center()
	touch_action.pressed = true
	var affinity_before_touch: int = mula.affinity
	scene._input(touch_action)
	assert(mula.affinity == affinity_before_touch, "Descansar novamente não deve multiplicar afinidade")
	assert(scene.mission.camp_rested, "Toque de interação deve descansar a comitiva")
	assert(player.virtual_direction == Vector2.RIGHT, "Segundo toque não deve interromper movimento")
	touch_move.pressed = false
	scene._input(touch_move)
	assert(player.virtual_direction == Vector2.ZERO, "Soltar toque deve parar")
	scene._show_dialogue("Teste", "Teste")
	scene._unhandled_input(cancel)
	assert(not scene.dialogue_box.visible, "Cancelar deve fechar diálogo")
	scene._set_input_device("controle")
	assert("Start" in scene.input_hint.text, "Instruções devem acompanhar controle")
	var start = InputEventJoypadButton.new()
	start.button_index = JOY_BUTTON_START
	start.pressed = true
	Input.parse_input_event(start)
	await process_frame
	assert(paused and scene.exploration_menu.panel.visible, "Start deve pausar pelo fluxo de entrada")
	await process_frame
	await process_frame
	var resume_touch = InputEventScreenTouch.new()
	resume_touch.index = 2
	resume_touch.pressed = true
	resume_touch.position = scene.exploration_menu.resume_button.get_global_rect().get_center()
	# Coordinates come from the viewport layout, not physical window pixels.
	root.push_input(resume_touch, true)
	await process_frame
	assert(not paused, "Toque em Continuar deve retomar árvore")
	scene.queue_free()
	await process_frame
	var creation = load("res://Scenes/CharacterSelect.tscn").instantiate()
	root.add_child(creation)
	await create_timer(0.7).timeout
	creation._transition_to_step(creation.Step.ORIGIN)
	await create_timer(1.1).timeout
	assert(root.gui_get_focus_owner() == creation.btn_confirm_origin, "Origem deve receber foco")
	creation._transition_to_step(creation.Step.CLASS)
	await create_timer(1.1).timeout
	assert(root.gui_get_focus_owner() == creation.btn_class_tropeiro, "Classe deve receber foco")
	print("CONTROLS_SMOKE_OK")
	quit()
