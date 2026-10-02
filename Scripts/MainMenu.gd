extends Control

@onready var btn_start = $ButtonsContainer/BtnStart
@onready var btn_archetypes = $ButtonsContainer/BtnArchetypes
@onready var btn_quit = $ButtonsContainer/BtnQuit

func _ready():
	btn_start.pressed.connect(_on_start_pressed)
	btn_archetypes.pressed.connect(_on_archetypes_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/CharacterSelect.tscn")

func _on_archetypes_pressed():
	get_tree().change_scene_to_file("res://Scenes/CharacterSelect.tscn")

func _on_quit_pressed():
	get_tree().quit()