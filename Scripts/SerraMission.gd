extends CanvasLayer

var scene: Node2D
var objective_panel: PanelContainer
var objective: Label
var bearing: Label
var marker: Node2D
var result_panel: PanelContainer
var result_title: Label
var result_text: Label
var retry_button: Button
var menu_button: Button
var camp_rested: bool = false
var finished: bool = false
var won: bool = false
var falls: int = 0
var elapsed: float = 0
var toast: Label
var toast_timer: float = 0
var checkpoint_position: Vector2

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 15
	scene = get_parent()
	_build_hud()
	_build_world_bounds()
	_build_river()
	_build_prop_collisions()
	call_deferred("_initialize_mission")

func _initialize_mission():
	if GameManager.current_cargo.is_empty():
		GameManager.select_cargo("sal_charque")
		scene._update_hud()
	var checkpoint = GameManager.read_serra_checkpoint() if GameManager.serra_resume_requested else {}
	GameManager.serra_resume_requested = false
	scene.player.travel_speed_factor = float(GameManager.current_cargo.get("velocidade_micro",1.0))
	if not checkpoint.is_empty():
		_restore(checkpoint)
	else:
		checkpoint_position = scene.player.global_position
		progress_changed()

func _build_hud():
	var panel = PanelContainer.new()
	objective_panel = panel
	panel.position = Vector2(16,156)
	panel.size = Vector2(540,88)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06,0.10,0.07,0.94)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.border_color = Color(0.7,0.58,0.3)
	style.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel",style)
	add_child(panel)
	var rows = VBoxContainer.new()
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(rows)
	objective = Label.new()
	objective.add_theme_font_size_override("font_size",20)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rows.add_child(objective)
	bearing = Label.new()
	bearing.add_theme_font_size_override("font_size",17)
	bearing.add_theme_color_override("font_color",Color(1,0.85,0.48))
	rows.add_child(bearing)
	toast = Label.new()
	toast.position = Vector2(24,252)
	toast.size.x = 524
	toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast.add_theme_font_size_override("font_size",20)
	toast.add_theme_stylebox_override("normal",style.duplicate())
	toast.hide()
	add_child(toast)
	marker = preload("res://Scripts/MissionWaypoint.gd").new()
	marker.z_index = 40
	scene.add_child.call_deferred(marker)
	result_panel = PanelContainer.new()
	result_panel.position = Vector2(34,270)
	result_panel.size = Vector2(504,420)
	var result_style = style.duplicate()
	result_style.bg_color = Color(0.06,0.10,0.07,0.99)
	result_style.content_margin_left = 24
	result_style.content_margin_right = 24
	result_style.content_margin_top = 24
	result_style.content_margin_bottom = 24
	result_panel.add_theme_stylebox_override("panel", result_style)
	add_child(result_panel)
	var result_rows = VBoxContainer.new()
	result_rows.add_theme_constant_override("separation",20)
	result_panel.add_child(result_rows)
	result_title = Label.new()
	result_title.add_theme_font_size_override("font_size",28)
	result_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_rows.add_child(result_title)
	result_text = Label.new()
	result_text.add_theme_font_size_override("font_size",20)
	result_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_rows.add_child(result_text)
	retry_button = Button.new()
	retry_button.custom_minimum_size.y = 72
	retry_button.pressed.connect(_retry)
	result_rows.add_child(retry_button)
	menu_button = Button.new()
	menu_button.text = "Voltar ao menu"
	menu_button.custom_minimum_size.y = 72
	menu_button.pressed.connect(_menu)
	result_rows.add_child(menu_button)
	result_panel.hide()

func _process(delta):
	if finished or get_tree().paused:
		return
	toast_timer = maxf(0,toast_timer-delta)
	toast.visible = toast_timer > 0
	elapsed += delta
	var target = next_target()
	objective.text = target["text"]
	var node = scene.get_node("YSortContainer/" + target["node"])
	var direction: Vector2 = node.global_position - scene.player.global_position
	marker.position = node.global_position + Vector2(0,-55)
	if scene.current_interactable:
		bearing.text = "Interagir: " + str(scene.current_interactable.get("speaker", "objeto próximo")).capitalize()
	else:
		var compass = ["Leste","Sudeste","Sul","Sudoeste","Oeste","Noroeste","Norte","Nordeste"]
		var index = posmod(roundi(direction.angle() / (PI/4)),8)
		bearing.text = "%s · %d passos · siga a trilha" % [compass[index],maxi(1,roundi(direction.length()/16))]

func next_target() -> Dictionary:
	if not scene.chest_opened:
		return {"node":"RanchoBau","text":"1/4 · Busque as provisões no baú do rancho"}
	if not camp_rested:
		return {"node":"RanchoFogueira","text":"2/4 · Descanse a comitiva na fogueira"}
	if not scene.caipora_offering_done:
		return {"node":"AltarCaipora","text":"3/4 · Leve o fumo ao altar da Caipora"}
	return {"node":"CruzeiroTopo","text":"4/4 · Entregue a carga no marco do planalto"}

func progress_changed():
	if finished:
		return
	checkpoint_position = scene.player.global_position
	GameManager.write_serra_checkpoint({
		"version":1,"position":[checkpoint_position.x,checkpoint_position.y],
		"chest":scene.chest_opened,"rested":camp_rested,"offering":scene.caipora_offering_done,
		"waterfall_chest":scene.waterfall_chest_opened,"rumor":GameManager.boato_cachoeira_descoberto,
		"inventory":GameManager.inventory.duplicate(),"cargo":GameManager.current_cargo.get("id","sal_charque"),
		"hp":GameManager.current_archetype["vida_atual"],"affinity":scene.mula.affinity,
		"period":GameManager.periodo_partida,"falls":falls,"elapsed":elapsed
	})

func _restore(data: Dictionary):
	GameManager.select_cargo(str(data.get("cargo","sal_charque")))
	scene.player.travel_speed_factor = float(GameManager.current_cargo.get("velocidade_micro",1.0))
	GameManager.inventory.clear()
	for item in data.get("inventory",[]):
		if item is String:
			GameManager.inventory.append(item)
	scene.chest_opened = bool(data.get("chest",false))
	camp_rested = bool(data.get("rested",false))
	scene.caipora_offering_done = bool(data.get("offering",false))
	scene.waterfall_chest_opened = bool(data.get("waterfall_chest",false))
	GameManager.boato_cachoeira_descoberto = bool(data.get("rumor",false))
	var pos = data["position"]
	checkpoint_position = Vector2(clampf(float(pos[0]),32,1684),clampf(float(pos[1]),32,2208))
	scene.player.global_position = checkpoint_position
	scene.mula.global_position = checkpoint_position + Vector2(34,54)
	scene.player.get_node("Camera2D").reset_smoothing()
	GameManager.current_archetype["vida_atual"] = clampi(int(data.get("hp",24)),1,GameManager.current_archetype["vida_max"])
	scene.mula.affinity = clampi(int(data.get("affinity",100)),30,150)
	falls = int(data.get("falls",0))
	elapsed = float(data.get("elapsed",0))
	scene._update_hud()
	scene._show_dialogue("Viagem retomada", "A comitiva está no último ponto seguro. O próximo objetivo está indicado no alto da tela.")

func register_fall():
	falls += 1
	if GameManager.current_archetype["vida_atual"] <= 0:
		_show_result(false)

func complete():
	if not scene.chest_opened or not camp_rested or not scene.caipora_offering_done:
		scene._show_dialogue("A carga ainda precisa de preparo", "Conclua os preparativos indicados no objetivo antes de encerrar a entrega.")
		return
	GameManager.clear_serra_checkpoint()
	_show_result(true)

func _show_result(success: bool):
	if finished:
		return
	finished = true
	won = success
	marker.hide()
	scene.dialogue_box.hide()
	scene.player.input_blocked = true
	scene.player.virtual_direction = Vector2.ZERO
	scene.held_directions.clear()
	scene.active_touches.clear()
	result_title.text = "Entrega concluída!" if won else "A comitiva precisa de repouso"
	result_text.text = ("Você chegou ao planalto com a carga e a Bonita.

Tempo: %d min %02d s · Quedas: %d
Afinidade: %d%%" % [int(elapsed)/60,int(elapsed)%60,falls,scene.mula.affinity]) if won else "As quedas esgotaram sua vida. Retome do último checkpoint, com a vida restaurada, para tentar novamente."
	retry_button.text = "Jogar novamente" if won else "Retomar do checkpoint"
	result_panel.show()
	retry_button.grab_focus()
	get_tree().paused = true

func _input(event):
	if finished and event is InputEventScreenTouch and event.pressed:
		for button in [retry_button,menu_button]:
			if button.get_global_rect().has_point(event.position):
				button.pressed.emit()
				break
		get_viewport().set_input_as_handled()

func _retry():
	get_tree().paused = false
	GameManager.serra_resume_requested = not won
	if not won:
		var data = GameManager.read_serra_checkpoint()
		if not data.is_empty():
			data["hp"] = GameManager.current_archetype["vida_max"]
			data["falls"] = falls
			data["elapsed"] = elapsed
			GameManager.write_serra_checkpoint(data)
	else:
		GameManager.select_archetype_by_id("tropeiro")
		GameManager.select_cargo("sal_charque")
	get_tree().reload_current_scene()

func _menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _build_world_bounds():
	var body = StaticBody2D.new()
	body.name = "WorldBoundary"
	scene.add_child.call_deferred(body)
	for rect in [Rect2(-32,-32,1780,32),Rect2(-32,2240,1780,32),Rect2(-32,0,32,2240),Rect2(1716,0,32,2240)]:
		var col = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = rect.size
		col.shape = shape
		col.position = rect.get_center()
		body.add_child(col)
	var coast_outline = scene.get_node("GroundLayer/OceanEstuary").polygon
	# The pier is walkable; remove its deck from the otherwise solid estuary.
	var dock = PackedVector2Array([Vector2(979,1845),Vector2(1031,1845),Vector2(1031,2070),Vector2(979,2070)])
	for outline in Geometry2D.clip_polygons(coast_outline,dock):
		var coast = CollisionPolygon2D.new()
		coast.polygon = outline
		body.add_child(coast)

func _build_river():
	var river = Area2D.new()
	river.name = "RiverCurrent"
	river.collision_layer = 0
	river.collision_mask = 3
	var points = scene.get_node("GroundLayer/RioCubatao").points
	var banks = Geometry2D.offset_polyline(points,20,Geometry2D.JOIN_ROUND,Geometry2D.END_ROUND)
	var bridge = PackedVector2Array([Vector2(784,1378),Vector2(864,1378),Vector2(864,1462),Vector2(784,1462)])
	for bank in banks:
		for area in Geometry2D.clip_polygons(bank,bridge):
			var shape = CollisionPolygon2D.new()
			shape.polygon = area
			river.add_child(shape)
	river.body_entered.connect(func(body):
		if body.has_method("enter_water_zone"):
			body.enter_water_zone(0.45,3.5)
	)
	river.body_exited.connect(func(body):
		if body.has_method("exit_water_zone"):
			body.exit_water_zone()
	)
	scene.add_child.call_deferred(river)

func notify(text: String, color: Color = Color(1,0.86,0.45)):
	toast.text = text
	toast.add_theme_color_override("font_color",color)
	toast_timer = 3.0
	toast.show()

func _build_prop_collisions():
	for name in ["RanchoBau","RanchoFogueira","BauCachoeira","AltarCaipora","CruzeiroTopo","PlacaGarganta"]:
		var node = scene.get_node_or_null("YSortContainer/"+name)
		if not node:
			continue
		var body = StaticBody2D.new()
		body.name = "SolidBase"
		var col = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 10 if name == "PlacaGarganta" else 14
		col.shape = shape
		body.add_child(col)
		node.add_child.call_deferred(body)

func resize_hud(size: Vector2i):
	objective_panel.position.y = 116 if size.x > 600 else 156
	objective_panel.size.x = minf(480 if size.x > 600 else 540, size.x - 32)
	toast.position.y = objective_panel.position.y + objective_panel.size.y + 8
	result_panel.position = Vector2((size.x-504)*0.5,maxf(100,(size.y-420)*0.5))
