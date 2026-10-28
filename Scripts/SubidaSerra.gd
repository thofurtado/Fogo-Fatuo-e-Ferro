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

var input_hint: Label
var input_device: String = ""
var exploration_menu: CanvasLayer
var held_directions: Dictionary = {}
var touch_controls: Array[Button] = []
var active_touches: Dictionary = {}
var previous_touch_mouse_emulation: bool
var inventory_close_button: Button
var current_interactable = null
var chest_opened: bool = false
var waterfall_chest_opened: bool = false
var caipora_offering_done: bool = false

func _ready():
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
		_show_dialogue("SUBIDA DA SERRA — PARTIDA NOTURNA (1645)", "A noite serasteira envolve a mata em trevas e névoa densa. Apenas as tochas e o luar prateado revelam os contornos das pedras. A mulinha Bonita bufa atenta com as orelhas em pé, farejando os assobios na escuridão. Use as ações indicadas no alto da tela.")
	else:
		modulate_node.color = Color(1.0, 0.98, 0.92, 1.0) # Luz límpida da manhã
		add_child(modulate_node)
		_show_dialogue("SUBIDA DA SERRA — PARTIDA NA ALVORADA (1645)", "A claridade da manhã dissipa a neblina do litoral. Diante de você, o paredão colossal da Serra do Mar e a subida de Paranapiacaba estão visíveis e límpidos. A mulinha Bonita segue firme na trilha! Use as ações indicadas no alto da tela.")

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

func _exit_tree():
	Input.emulate_mouse_from_touch = previous_touch_mouse_emulation

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
				if inventory_close_button.get_global_rect().has_point(event.position):
					_toggle_inventory()
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
			dialogue_box.visible = false
		get_viewport().set_input_as_handled()
	elif (event.is_action_pressed("serra_interact") or event.is_action_pressed("ui_accept")) and not event.is_echo():
		if not inventory_panel.visible:
			_handle_interaction()
		get_viewport().set_input_as_handled()

func _toggle_inventory():
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
	dialogue_box.offset_top = -460
	dialogue_box.offset_bottom = -205
	_add_direction_button(controls, "▲", Vector2(97, -196), Vector2.UP)
	_add_direction_button(controls, "◀", Vector2(15, -114), Vector2.LEFT)
	_add_direction_button(controls, "▼", Vector2(97, -114), Vector2.DOWN)
	_add_direction_button(controls, "▶", Vector2(179, -114), Vector2.RIGHT)
	_add_action_button(controls, "Interagir", Vector2(-150, -196), _handle_screen_interaction)
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

func _add_action_button(parent: Control, label: String, offset: Vector2, callback: Callable):
	var button = _make_control_button(parent, label, offset, Vector2(135, 78))
	touch_controls.append(button)
	button.pressed.connect(callback)

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

func _show_dialogue(speaker: String, text: String):
	dialogue_speaker.add_theme_font_size_override("font_size", 18)
	dialogue_text.add_theme_font_size_override("font_size", 20)
	dialogue_speaker.text = speaker
	dialogue_text.text = text
	dialogue_box.visible = true

func register_target(id: String, speaker: String, text: String):
	current_interactable = {"id": id, "speaker": speaker, "text": text}
	_show_dialogue(speaker, text)

func unregister_target(id: String):
	if current_interactable and current_interactable["id"] == id:
		current_interactable = null
		dialogue_box.visible = false

func _handle_interaction():
	if not current_interactable:
		if dialogue_box.visible:
			dialogue_box.visible = false
		return
		
	var id = current_interactable["id"]
	match id:
		"bau_rancho":
			if not chest_opened:
				chest_opened = true
				GameManager.add_item("Feijão Tropeiro Nutritivo (+6 HP)")
				GameManager.add_item("Facão de Três Listras (Aço Forjado)")
				GameManager.add_item("Fumo de Rolo de Oferenda")
				mula.add_affinity(10)
				_update_hud()
				_show_dialogue("BAÚ DO RANCHO:", "Você recolheu rações de Feijão Tropeiro, um Facão de trilha e Fumo de Rolo perfumado! A mula Bonita agradece a fartura (+10% Afinidade).")
			else:
				_show_dialogue("BAÚ DO RANCHO:", "O baú de ferro está vazio.")
		"fogueira_rancho":
			var arch = GameManager.current_archetype
			arch["vida_atual"] = arch["vida_max"]
			mula.add_affinity(15)
			_update_hud()
			_show_dialogue("FOGUEIRA DE POUSO:", "Você bebe um café de milho quente e faz carinho nas orelhas da Bonita junto às brasas. Vida restaurada ao máximo e a mula descansou (+15% Afinidade)!")
		"placa_garganta":
			_show_dialogue("MARCO DA GARGANTA DAS ÁGUAS:", "« Cuidado viajante: A cachoeira esculpiu abismos nas pedras. Empurre os barris de cascalho para firmar a passagem sobre as poças de barro! »")
		"bau_cachoeira":
			if GameManager.boato_cachoeira_descoberto:
				if not waterfall_chest_opened:
					waterfall_chest_opened = true
					GameManager.add_item("40 Patacas de Prata Jesuítas")
					GameManager.add_item("Terço de Jacarandá Sagrado")
					mula.add_affinity(20)
					_update_hud()
					_show_dialogue("BAÚ DA CACHOEIRA DO VÉU (BOATO CONFIRMADO!):", "Lembrando-se do segredo sussurrado na taverna de Santos, você enfia os braços nas fendas escuras atrás da cascata... e puxa o velho baú de ferro! Você encontrou 40 Patacas de Prata e um Terço de Jacarandá! (+20% Afinidade da Mula).")
				else:
					_show_dialogue("CACHOEIRA DO VÉU:", "A fenda atrás das pedras está vazia. Você já resgatou o tesouro do bandeirante.")
			else:
				_show_dialogue("CACHOEIRA DO VÉU:", "A água desce ruidosa e gelada pelas pedras escorregadias. Parece haver fendas profundas na rocha úmida, mas sem saber o que procurar, é perigoso colocar as mãos.")
		"altar_caipora":
			if not caipora_offering_done:
				caipora_offering_done = true
				mula.add_affinity(25)
				_update_hud()
				_show_dialogue("O BAMBUZAL DA CAIPORA:", "Você deposita o naco de fumo de rolo na forquilha da árvore. Um redemoinho de folhas perfumadas sobe pelo ar e um assobio brando ecoa na serra... A dona da mata abençoou sua tropa! (+25% Afinidade).")
			else:
				_show_dialogue("ALTAR DA CAIPORA:", "As cinzas de fumo aromático repousam em paz. A floresta está calma e a passagem está aberta.")
		"cruzeiro_topo":
			_show_dialogue("A GRANDE ENCRUZILHADA DA SERRA:", "Você superou a subida de Paranapiacaba! Diante de você abre-se o Planalto de Piratininga. As rotas dos tropeiros, batedores e desertores se cruzam sob o olhar do Fogo-Fátuo...")

func on_player_fell_ledge(hp_loss: int, aff_loss: int):
	if mula:
		mula.add_affinity(-aff_loss)
	_update_hud()
	_show_dialogue("⚠️ QUEDA NA ESCARPA!", "Você escorregou pelo despenhadeiro de pedra da serra! Cascalho e poeira voaram morro abaixo. A mula Bonita relinchou sobressaltada com o salto abrupto! (-%d HP | -%d%% Afinidade da Mula). Cuidado com o barranco: siga as curvas calçadas da trilha para subir em segurança!" % [hp_loss, aff_loss])
