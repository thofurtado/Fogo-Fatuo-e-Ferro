extends Control

@onready var btn_start = $ButtonsContainer/BtnStart
@onready var btn_prologo = $ButtonsContainer/BtnPrologo
@onready var btn_subida = $ButtonsContainer/BtnSubida
@onready var btn_quit = $ButtonsContainer/BtnQuit

func _ready():
	btn_start.pressed.connect(_on_start_pressed)
	if btn_prologo:
		btn_prologo.pressed.connect(_on_prologo_pressed)
	if btn_subida:
		btn_subida.pressed.connect(_on_subida_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)
	# quit() nao faz nada no navegador
	btn_quit.visible = not OS.has_feature("web")
	btn_subida.text = "Jogar · Entrega na Serra"
	btn_subida.custom_minimum_size.y = 64
	$ButtonsContainer.move_child(btn_subida, 0)
	$ButtonsContainer.offset_top = -350
	if not GameManager.read_serra_checkpoint().is_empty():
		var continue_button = Button.new()
		continue_button.text = "Continuar viagem"
		continue_button.custom_minimum_size.y = 60
		continue_button.pressed.connect(_continue_serra)
		$ButtonsContainer.add_child(continue_button)
		$ButtonsContainer.move_child(continue_button, 0)
		continue_button.grab_focus()
	else:
		btn_subida.grab_focus()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/CharacterSelect.tscn")

func _on_prologo_pressed():
	GameManager.select_archetype_by_id("tropeiro")
	GameManager.selected_region_id = 4
	get_tree().change_scene_to_file("res://Scenes/PrologoTropeiro.tscn")

func _on_subida_pressed():
	GameManager.serra_resume_requested = false
	GameManager.periodo_partida = "alvorada"
	GameManager.select_archetype_by_id("tropeiro")
	GameManager.select_cargo("sal_charque")
	get_tree().change_scene_to_file("res://Scenes/SubidaSerra.tscn")

func _on_quit_pressed():
	get_tree().quit()
func _continue_serra():
	var data = GameManager.read_serra_checkpoint()
	GameManager.select_archetype_by_id("tropeiro")
	GameManager.periodo_partida = str(data.get("period","alvorada"))
	GameManager.serra_resume_requested = true
	get_tree().change_scene_to_file("res://Scenes/SubidaSerra.tscn")
