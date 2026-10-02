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
	# Transição para a floresta
	feedback_panel.visible = true
	feedback_label.text = "VOCÊ MERGULHA NA ESCURIDÃO DA MATA FECHADA...\nOS ESPÍRITOS DA FLORESTA ACORDAM!"
	await get_tree().create_timer(1.8).timeout
	get_tree().change_scene_to_file("res://Scenes/ForestGame.tscn")

func _on_lutar_pressed():
	feedback_panel.visible = true
	feedback_label.text = "SUAS FLECHAS REBATEM NAS ARMADURAS DE FERRO!\nA MATA PUXA SEU BRAÇO PARA QUE VOCÊ SOBREVIVA..."
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://Scenes/ForestGame.tscn")

func _on_resgatar_pressed():
	feedback_panel.visible = true
	feedback_label.text = "VOCÊ ESCONDE AS CRIANÇAS NO OCO DA JAQUEIRA SAGRADA E PARTE PARA DESPISTAR OS INVASORES!"
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://Scenes/ForestGame.tscn")