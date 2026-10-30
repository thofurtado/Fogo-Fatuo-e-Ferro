extends CanvasLayer

var panel: PanelContainer
var pause_button: Button
var resume_button: Button
var fullscreen_button: Button
var menu_button: Button
var volume: HSlider
var touch_slider_index: int = -1

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	pause_button = Button.new()
	pause_button.text = "Pausa"
	pause_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pause_button.offset_left = -122
	pause_button.offset_right = -16
	pause_button.offset_top = 76
	pause_button.offset_bottom = 148
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.pressed.connect(_toggle_pause)
	add_child(pause_button)
	panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background = StyleBoxFlat.new()
	background.bg_color = Color(0.07, 0.09, 0.07, 0.97)
	background.content_margin_left = 48
	background.content_margin_right = 48
	background.content_margin_top = 64
	background.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", background)
	add_child(panel)
	var items = VBoxContainer.new()
	items.add_theme_constant_override("separation", 22)
	panel.add_child(items)
	var title = Label.new()
	title.text = "Uma pausa na jornada"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	items.add_child(title)
	resume_button = _button(items, "Continuar", _toggle_pause)
	var volume_label = Label.new()
	volume_label.text = "Volume geral"
	items.add_child(volume_label)
	volume = HSlider.new()
	volume.custom_minimum_size.y = 72
	volume.min_value = 0
	volume.max_value = 100
	volume.value = db_to_linear(AudioServer.get_bus_volume_db(0)) * 100
	volume.value_changed.connect(func(value): AudioServer.set_bus_volume_db(0, linear_to_db(maxf(value / 100.0, 0.0001))))
	items.add_child(volume)
	fullscreen_button = _button(items, "Alternar tela cheia", _toggle_fullscreen)
	menu_button = _button(items, "Voltar ao menu (último checkpoint)", _return_to_menu)
	panel.hide()

func _button(parent: Control, text: String, callback: Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size", 20)
	button.custom_minimum_size.y = 76
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _input(event: InputEvent):
	if event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START:
		_toggle_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and not event.is_echo():
		var scene = get_parent()
		if panel.visible or (not scene.inventory_panel.visible and not scene.dialogue_box.visible):
			_toggle_pause()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch:
		if event.pressed:
			if panel.visible:
				for button in [resume_button, fullscreen_button, menu_button]:
					if button.get_global_rect().has_point(event.position):
						button.pressed.emit()
						get_viewport().set_input_as_handled()
						return
				if volume.get_global_rect().has_point(event.position):
					touch_slider_index = event.index
					_set_touch_volume(event.position.x)
				get_viewport().set_input_as_handled()
			elif pause_button.get_global_rect().has_point(event.position):
				_toggle_pause()
				get_viewport().set_input_as_handled()
		elif event.index == touch_slider_index:
			touch_slider_index = -1
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and panel.visible:
		if event.index == touch_slider_index:
			_set_touch_volume(event.position.x)
		get_viewport().set_input_as_handled()

func _set_touch_volume(x: float):
	var rect = volume.get_global_rect()
	volume.value = clampf((x - rect.position.x) / rect.size.x, 0, 1) * 100

func _toggle_pause():
	if get_parent().mission and get_parent().mission.finished:
		return
	var paused = not panel.visible
	panel.visible = paused
	pause_button.visible = not paused
	get_tree().paused = paused
	get_parent().held_directions.clear()
	get_parent().active_touches.clear()
	get_parent().player.virtual_direction = Vector2.ZERO
	if paused:
		resume_button.grab_focus()
	else:
		resume_button.release_focus()
		if get_parent().inventory_panel.visible:
			get_parent().inventory_close_button.grab_focus()

func _toggle_fullscreen():
	var mode = DisplayServer.window_get_mode()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if mode == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)

func _return_to_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
