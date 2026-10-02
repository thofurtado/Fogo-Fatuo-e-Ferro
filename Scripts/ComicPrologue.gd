extends Control

@onready var btn_fugir = $PanelContainer/VBoxContainer/HBoxContainer/BtnFugir
@onready var btn_lutar = $PanelContainer/VBoxContainer/HBoxContainer/BtnLutar
@onready var btn_resgatar = $PanelContainer/VBoxContainer/HBoxContainer/BtnResgatar
@onready var feedback_label = $FeedbackPanel/FeedbackLabel
@onready var feedback_panel = $FeedbackPanel

func _ready():
	feedback_panel.visible = false
	btn_fugir.pressed.connect(_on_fugir_pressed)
	btn_lutar.pressed.connect(_on_lutar_pressed)
	btn_resgatar.pressed.connect(_on_resgatar_pressed)

func _on_fugir_pressed():
	feedback_panel.visible = true
	feedback_label.text = "VOC? MERGULHA NA MATA FECHADA...\nOS ESP?RITOS DA FLORESTA ACORDAM!"
	await get_tree().create_timer(1.8).timeout
	get_tree().change_scene_to_file("res://Scenes/MataTileMap.tscn")

func _on_lutar_pressed():
	feedback_panel.visible = true
	feedback_label.text = "SUAS FLECHAS REBATEM NAS ARMADURAS DE FERRO!\nA MATA PUXA SEU CORPO PARA QUE VOC? SOBREVIVA..."
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/MataTileMap.tscn")

func _on_resgatar_pressed():
	feedback_panel.visible = true
	feedback_label.text = "VOC? DESPISTA OS INVASORES E ENTRA NAS TRILHAS DA SERRA!"
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/MataTileMap.tscn")
