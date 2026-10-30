extends Node2D

@onready var player = $YSortContainer/Player
@onready var mula = $YSortContainer/MulaBonita

@onready var hud_hero_name = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HeroLabel
@onready var hud_hp = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HpLabel
@onready var hud_affinity = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/AffinityLabel
@onready var hud_cargo = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/CargoLabel

@onready var dialogue_box = $UILayer/DialogueBox
@onready var dialogue_speaker = $UILayer/DialogueBox/MarginContainer/VBoxContainer/Speaker
@onready var dialogue_text = $UILayer/DialogueBox/MarginContainer/VBoxContainer/DialogueText

@onready var inventory_panel = $UILayer/InventoryPanel
@onready var inventory_text = $UILayer/InventoryPanel/MarginContainer/VBoxContainer/ItemListLabel

const FOOD_ITEM = "Feijão tropeiro (+6 vida)"
const OFFERING_ITEM = "Fumo de rolo para a Caipora"
var mission: CanvasLayer
var interaction_button: Button
var food_button: Button
var input_hint: Label
var input_device: String = ""
var exploration_menu: CanvasLayer
var held_directions: Dictionary = {}
var touch_controls: Array[Button] = []
var active_touches: Dictionary = {}
var previous_canvas_size: Vector2i
var previous_touch_mouse_emulation: bool
var dialogue_close_button: Button
var inventory_close_button: Button
var nearby_targets: Dictionary = {}
var current_interactable = null
var chest_opened: bool = false
var waterfall_chest_opened: bool = false
var caipora_offering_done: bool = false

func _ready():
	previous_canvas_size = get_window().content_scale_size
	_configure_screen()
	previous_touch_mouse_emulation = Input.emulate_mouse_from_touch
	Input.emulate_mouse_from_touch = false
	_setup_controls()
	exploration_menu = preload("res://Scripts/ExplorationMenu.gd").new()
	add_child(exploration_menu)
	dialogue_box.visible = false
	inventory_panel.visible = false
	
	# Garante que a comitiva do Tropeiro está ativa (se não veio pelo prólogo)
	if GameManager.current_archetype.is_empty():
		GameManager.select_archetype_by_id("tropeiro")
	_update_hud()
	
	# Iluminação e clima atmosférico conforme escolha na Estalagem (Noite x Alvorada)
	var modulate_node = CanvasModulate.new()
	if GameManager.periodo_partida == "noite":
		modulate_node.color = Color(0.42, 0.48, 0.75, 1.0) # Luz noturna azulada
		add_child(modulate_node)
		_show_dialogue("SUBIDA DA SERRA — PARTIDA NOTURNA (1645)", "Sua entrega está no lombo da Bonita. Leve a carga de Santos ao planalto. Siga a trilha até o rancho e busque as provisões; o objetivo no alto da tela indica a direção.")
	else:
		modulate_node.color = Color(1.0, 0.98, 0.92, 1.0) # Luz límpida da manhã
		add_child(modulate_node)
		_show_dialogue("SUBIDA DA SERRA — PARTIDA NA ALVORADA (1645)", "Leve a carga de Santos ao planalto com a Bonita. Primeiro, siga a trilha até o rancho e recolha as provisões. O marcador dourado e o objetivo no alto da tela guiam sua jornada.")

	# Conexões das áreas de interação
	$YSortContainer/RanchoFogueira.body_entered.connect(func(b): if b == player: register_target("fogueira_rancho", "FOGUEIRA DE POUSO", "Brasas quentes de café de milho. Use Interagir para descansar e tratar a mula."))
	$YSortContainer/RanchoFogueira.body_exited.connect(func(b): if b == player: unregister_target("fogueira_rancho"))

	$YSortContainer/RanchoBau.body_entered.connect(func(b): if b == player: register_target("bau_rancho", "BAÚ DO RANCHO", "Baú reforçado de ferro. Use Interagir para abrir."))
	$YSortContainer/RanchoBau.body_exited.connect(func(b): if b == player: unregister_target("bau_rancho"))

	$YSortContainer/PlacaGarganta.body_entered.connect(func(b): if b == player: register_target("placa_garganta", "MARCO DE MADEIRA", "Placa antiga de trilha. Use Interagir para ler."))
	$YSortContainer/PlacaGarganta.body_exited.connect(func(b): if b == player: unregister_target("placa_garganta"))

	if $YSortContainer.has_node("BauCachoeira"):
		$YSortContainer/BauCachoeira.body_entered.connect(func(b): if b == player: register_target("bau_cachoeira", "QUEDA D'ÁGUA DA CACHOEIRA DO VÉU", "O estrondo da água espirra neblina nas pedras. Use Interagir para inspecionar as fendas."))
		$YSortContainer/BauCachoeira.body_exited.connect(func(b): if b == player: unregister_target("bau_cachoeira"))

	$YSortContainer/AltarCaipora.body_entered.connect(func(b): if b == player: register_target("altar_caipora", "ALTAR DO BAMBUZAL", "Tronco e pedras rituais da Caipora. Use Interagir para deixar oferenda de Fumo."))
	$YSortContainer/AltarCaipora.body_exited.connect(func(b): if b == player: unregister_target("altar_caipora"))

	$YSortContainer/CruzeiroTopo.body_entered.connect(func(b): if b == player: register_target("cruzeiro_topo", "A GRANDE ENCRUZILHADA", "Cruzeiro de pedra no cume da serra. Use Interagir para contemplar o Planalto."))
	$YSortContainer/CruzeiroTopo.body_exited.connect(func(b): if b == player: unregister_target("cruzeiro_topo"))
	mission = preload("res://Scripts/SerraMission.gd").new()
	add_child(mission)
	var atmosphere = preload("res://Scripts/SerraAtmosphere.gd").new()
	add_child(atmosphere)
	get_window().size_changed.connect(_configure_screen)
	_configure_screen()

func _exit_tree():
	if get_window().size_changed.is_connected(_configure_screen):
		get_window().size_changed.disconnect(_configure_screen)
	get_window().content_scale_size = previous_canvas_size
	Input.emulate_mouse_from_touch = previous_touch_mouse_emulation

func _configure_screen():
	var size = get_window().size
	var ratio = float(size.x) / maxf(1,size.y)
	var logical = Vector2i(roundi(720*ratio),720) if ratio > 1.25 and not DisplayServer.is_touchscreen_available() else Vector2i(572,1024)
	if get_window().content_scale_size != logical:
		get_window().content_scale_size = logical
	if is_instance_valid(dialogue_box):
		dialogue_box.offset_top = -390 if logical.x > 600 else -460
	if is_instance_valid(input_hint):
		input_hint.size.x = logical.x - 152
	if is_instance_valid(mission):
		mission.resize_hud(logical)


func _input(event: InputEvent):
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf(event.axis_value) > 0.3):
		_set_input_device("controle")
	elif event is InputEventScreenTouch:
		_set_input_device("touch")
	elif event is InputEventKey:
		_set_input_device("teclado")
	elif event is InputEventMouseButton:
		_set_input_device("mouse")
	if event is InputEventScreenTouch:
		if event.pressed:
			if inventory_panel.visible:
				if food_button.visible and food_button.get_global_rect().has_point(event.position):
					_use_provision()
				elif inventory_close_button.get_global_rect().has_point(event.position):
					_toggle_inventory()
				get_viewport().set_input_as_handled()
				return
			if dialogue_box.visible and dialogue_close_button.get_global_rect().has_point(event.position):
				_dismiss_dialogue()
				get_viewport().set_input_as_handled()
				return
			var button = _touch_button_at(event.position)
			if button:
				active_touches[event.index] = button
				if button.has_meta("direction"):
					held_directions[event.index] = button.get_meta("direction")
					_update_virtual_direction()
				else:
					button.pressed.emit()
				get_viewport().set_input_as_handled()
		elif active_touches.has(event.index):
			active_touches.erase(event.index)
			held_directions.erase(event.index)
			_update_virtual_direction()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and active_touches.has(event.index):
		var previous_button: Button = active_touches[event.index]
		if previous_button.has_meta("direction"):
			var button = _touch_button_at(event.position)
			if button and button.has_meta("direction"):
				active_touches[event.index] = button
				held_directions[event.index] = button.get_meta("direction")
			else:
				held_directions.erase(event.index)
			_update_virtual_direction()
		get_viewport().set_input_as_handled()

func _touch_button_at(point: Vector2) -> Button:
	for button in touch_controls:
		if button.get_global_rect().has_point(point):
			return button
	return null

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("serra_inventory") and not event.is_echo():
		_toggle_inventory()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		if inventory_panel.visible:
			_toggle_inventory()
		elif dialogue_box.visible:
			_dismiss_dialogue()
		get_viewport().set_input_as_handled()
	elif (event.is_action_pressed("serra_interact") or event.is_action_pressed("ui_accept")) and not event.is_echo():
		if not inventory_panel.visible:
			_handle_interaction()
		get_viewport().set_input_as_handled()

func _toggle_inventory():
	if mission and mission.finished:
		return
	inventory_panel.visible = not inventory_panel.visible
	player.input_blocked = inventory_panel.visible
	if inventory_panel.visible:
		held_directions.clear()
		active_touches.clear()
		player.virtual_direction = Vector2.ZERO
		_refresh_inventory()
		inventory_close_button.grab_focus()
	else:
		inventory_close_button.release_focus()

func _setup_controls():
	_add_key_action("serra_interact", KEY_E)
	_add_key_action("serra_inventory", KEY_I)
	var joy_inventory = InputEventJoypadButton.new()
	joy_inventory.button_index = JOY_BUTTON_Y
	InputMap.action_add_event("serra_inventory", joy_inventory)
	dialogue_close_button = Button.new()
	dialogue_close_button.text = "Continuar"
	dialogue_close_button.focus_mode = Control.FOCUS_NONE
	dialogue_close_button.custom_minimum_size.y = 64
	dialogue_close_button.pressed.connect(_dismiss_dialogue)
	dialogue_box.get_node("MarginContainer/VBoxContainer").add_child(dialogue_close_button)
	food_button = Button.new()
	food_button.text = "Comer provisão (+6 vida)"
	food_button.custom_minimum_size.y = 72
	food_button.pressed.connect(_use_provision)
	inventory_panel.get_node("MarginContainer/VBoxContainer").add_child(food_button)
	inventory_close_button = Button.new()
	inventory_close_button.text = "Fechar"
	inventory_close_button.custom_minimum_size = Vector2(0, 72)
	inventory_close_button.pressed.connect(_toggle_inventory)
	inventory_panel.get_node("MarginContainer/VBoxContainer").add_child(inventory_close_button)
	input_hint = Label.new()
	input_hint.position = Vector2(16, 76)
	input_hint.size = Vector2(420, 48)
	input_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	input_hint.add_theme_font_size_override("font_size", 18)
	$UILayer.add_child(input_hint)
	_set_input_device("touch" if DisplayServer.is_touchscreen_available() else "teclado")
	var controls = Control.new()
	controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$UILayer.add_child(controls)
	# Leave room above the directional controls for the dialogue.
	dialogue_box.offset_top = -390
	dialogue_box.offset_bottom = -205
	_add_direction_button(controls, "▲", Vector2(97, -196), Vector2.UP)
	_add_direction_button(controls, "◀", Vector2(15, -114), Vector2.LEFT)
	_add_direction_button(controls, "▼", Vector2(97, -114), Vector2.DOWN)
	_add_direction_button(controls, "▶", Vector2(179, -114), Vector2.RIGHT)
	interaction_button = _add_action_button(controls, "Interagir", Vector2(-150, -196), _handle_screen_interaction)
	_add_action_button(controls, "Algibeira", Vector2(-150, -114), _toggle_inventory)

func _set_input_device(device: String):
	if device == input_device:
		return
	input_device = device
	match device:
		"controle": input_hint.text = "Analógico/direcional: andar | A: interagir | Y: algibeira | Start: pausa"
		"touch": input_hint.text = "Use o direcional e as ações na tela. Pausa no canto superior."
		"mouse": input_hint.text = "Segure as setas na tela para andar. Clique nas ações para usar."
		_: input_hint.text = "WASD/setas: andar | E: interagir | I: algibeira | Esc: voltar/pausa"

func _add_key_action(action: String, key: Key):
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event = InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_add_event(action, event)

func _make_control_button(parent: Control, label: String, offset: Vector2, size: Vector2) -> Button:
	var button = Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	button.set_anchors_preset(Control.PRESET_BOTTOM_LEFT if offset.x >= 0 else Control.PRESET_BOTTOM_RIGHT)
	button.position = offset
	button.size = size
	button.add_theme_font_size_override("font_size", 18)
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.12, 0.09, 0.94)
	normal.border_color = Color(0.66, 0.58, 0.35)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(5)
	button.add_theme_stylebox_override("normal", normal)
	var pressed = normal.duplicate()
	pressed.bg_color = Color(0.3, 0.32, 0.18, 0.98)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover", pressed)
	parent.add_child(button)
	return button

func _add_direction_button(parent: Control, label: String, offset: Vector2, direction: Vector2):
	var button = _make_control_button(parent, label, offset, Vector2(78, 78))
	button.set_meta("direction", direction)
	touch_controls.append(button)
	button.button_down.connect(func():
		if not inventory_panel.visible:
			held_directions[button] = direction
			_update_virtual_direction()
	)
	button.button_up.connect(func():
		held_directions.erase(button)
		_update_virtual_direction()
	)

func _update_virtual_direction():
	player.virtual_direction = Vector2.ZERO
	for direction in held_directions.values():
		player.virtual_direction += direction

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(player):
		active_touches.clear()
		held_directions.clear()
		player.virtual_direction = Vector2.ZERO

func _add_action_button(parent: Control, label: String, offset: Vector2, callback: Callable) -> Button:
	var button = _make_control_button(parent, label, offset, Vector2(135, 78))
	touch_controls.append(button)
	button.pressed.connect(callback)
	return button

func _handle_screen_interaction():
	if not inventory_panel.visible:
		_handle_interaction()

func _update_hud():
	var arch = GameManager.current_archetype
	hud_hero_name.text = "🤠 " + arch["name"]
	hud_hp.text = "♥ HP: %d/%d" % [arch["vida_atual"], arch["vida_max"]]
	
	var aff = mula.affinity if mula else 100
	var status = "Dócil"
	if aff >= 120:
		status = "Irmã de Alma"
	elif aff < 50:
		status = "Arredia"
	hud_affinity.text = "🐴 Mula: %d%% [%s]" % [aff, status]
	
	if GameManager.current_cargo.has("name"):
		hud_cargo.text = "📦 " + GameManager.current_cargo["name"]
	else:
		hud_cargo.text = "📦 Carga: Fardo de Sal & Charque"

func _refresh_inventory():
	var text = "🎒 ITENS NA ALGIBEIRA:\n"
	for item in GameManager.inventory:
		text += " • " + item + "\n"
	if GameManager.current_cargo.has("name"):
		text += "\n🐴 CARGA NAS BRUACAS DA MULA:\n • " + GameManager.current_cargo["name"]
		text += "\n   (Peso: %s | Marcha da Tropa: %d%%)" % [GameManager.current_cargo["peso"], int(GameManager.current_cargo["velocidade_micro"] * 100)]
	inventory_text.text = text
	food_button.visible = GameManager.inventory.has(FOOD_ITEM)

func _show_dialogue(speaker: String, text: String):
	dialogue_speaker.add_theme_font_size_override("font_size", 18)
	dialogue_text.add_theme_font_size_override("font_size", 20)
	dialogue_speaker.text = speaker
	dialogue_text.text = text
	dialogue_box.visible = true
	interaction_button.text = "Continuar"

func _dismiss_dialogue():
	dialogue_box.hide()
	interaction_button.text = "Interagir"

func register_target(id: String, speaker: String, text: String):
	nearby_targets[id] = {"id":id,"speaker":speaker,"text":text}
	current_interactable = nearby_targets[id]
	interaction_button.text = "Continuar" if dialogue_box.visible else "Interagir"

func unregister_target(id: String):
	nearby_targets.erase(id)
	if current_interactable and current_interactable["id"] == id:
		current_interactable = null if nearby_targets.is_empty() else nearby_targets.values().back()
		_dismiss_dialogue()

func _use_provision():
	if not GameManager.inventory.has(FOOD_ITEM):
		return
	var arch = GameManager.current_archetype
	if arch["vida_atual"] >= arch["vida_max"]:
		inventory_text.text += "\nVocê já está com a vida cheia."
		return
	GameManager.inventory.erase(FOOD_ITEM)
	arch["vida_atual"] = mini(arch["vida_max"], arch["vida_atual"] + 6)
	_refresh_inventory()
	_update_hud()
	mission.progress_changed()

func _handle_interaction():
	if dialogue_box.visible:
		_dismiss_dialogue()
		return
	if mission and mission.finished:
		return
	if not current_interactable:
		dialogue_box.hide()
		return
	var id = current_interactable["id"]
	match id:
		"bau_rancho":
			if not chest_opened:
				chest_opened = true
				GameManager.add_item(FOOD_ITEM)
				GameManager.add_item(OFFERING_ITEM)
				mula.add_affinity(10)
				_update_hud()
				_show_dialogue("Provisões recolhidas", "Você guardou uma refeição e o fumo da oferenda. A refeição recupera 6 pontos de vida pela algibeira. Agora prepare a comitiva na fogueira.")
				mission.progress_changed()
			else:
				_show_dialogue("Baú vazio", "As provisões já estão com você. Veja o próximo objetivo no alto da tela.")
		"fogueira_rancho":
			GameManager.current_archetype["vida_atual"] = GameManager.current_archetype["vida_max"]
			if not mission.camp_rested:
				mula.add_affinity(15)
			mission.camp_rested = true
			_update_hud()
			_show_dialogue("Comitiva descansada", "Vida restaurada. A Bonita está pronta. Seu progresso foi guardado neste pouso; siga a trilha até o altar da Caipora.")
			mission.progress_changed()
		"placa_garganta":
			GameManager.boato_cachoeira_descoberto = true
			_show_dialogue("O segredo da cachoeira", "Um viajante escondeu um baú junto à queda d'água. É um desvio opcional. Na subida, siga as curvas: descer uma escarpa custa vida.")
		"bau_cachoeira":
			if not GameManager.boato_cachoeira_descoberto:
				_show_dialogue("Uma fenda sob a água", "Talvez a placa da trilha explique o que há neste lugar.")
			elif not waterfall_chest_opened:
				waterfall_chest_opened = true
				GameManager.add_item("40 patacas de prata")
				mula.add_affinity(20)
				_update_hud()
				_show_dialogue("Tesouro encontrado", "Você encontrou 40 patacas! A entrega continua; volte à trilha indicada pelo objetivo.")
				mission.progress_changed()
			else:
				_show_dialogue("Fenda vazia", "Você já recolheu o tesouro.")
		"altar_caipora":
			if caipora_offering_done:
				_show_dialogue("Passagem abençoada", "A oferenda já foi aceita. Siga até o marco do planalto.")
			elif not GameManager.inventory.has(OFFERING_ITEM):
				_show_dialogue("Falta a oferenda", "O altar pede fumo de rolo. Há provisões no baú do rancho; não entregue a carga sem preparar a comitiva.")
			else:
				GameManager.inventory.erase(OFFERING_ITEM)
				caipora_offering_done = true
				mula.add_affinity(25)
				_update_hud()
				_show_dialogue("A Caipora aceitou", "Um assobio brando percorre a mata. O fumo foi consumido e a comitiva recebeu a bênção. Seu progresso foi guardado; leve a carga ao marco do planalto.")
				mission.progress_changed()
		"cruzeiro_topo":
			mission.complete()

func on_player_fell_ledge(hp_loss: int, aff_loss: int):
	if mula:
		mula.add_affinity(-aff_loss)
	_update_hud()
	player.sprite.modulate = Color(1,0.45,0.38)
	player.create_tween().tween_property(player.sprite,"modulate",Color.WHITE,0.4)
	mission.notify("Queda: -%d vida · siga as curvas da trilha" % hp_loss,Color(1,0.5,0.4))
	if mission:
		mission.register_fall()
