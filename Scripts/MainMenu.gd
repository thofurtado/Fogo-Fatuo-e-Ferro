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

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/CharacterSelect.tscn")

func _on_prologo_pressed():
	GameManager.select_archetype_by_id("tropeiro")
	GameManager.selected_region_id = 4
	get_tree().change_scene_to_file("res://Scenes/PrologoTropeiro.tscn")

func _on_subida_pressed():
	GameManager.select_archetype_by_id("tropeiro")
	GameManager.select_cargo("sal_charque")
	get_tree().change_scene_to_file("res://Scenes/SubidaSerra.tscn")

func _on_quit_pressed():
	get_tree().quit()