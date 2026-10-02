extends Control

@onready var btn_fugir = $Hotspots/BtnFugir
@onready var btn_lutar = $Hotspots/BtnLutar
@onready var btn_resgatar = $Hotspots/BtnResgatar
@onready var feedback_label = $FeedbackPanel/FeedbackLabel
@onready var feedback_panel = $FeedbackPanel

var transitioning = false

func _ready():
	feedback_panel.visible = false
	btn_fugir.pressed.connect(_on_fugir_pressed)
	btn_lutar.pressed.connect(_on_lutar_pressed)
	btn_resgatar.pressed.connect(_on_resgatar_pressed)

func _on_fugir_pressed():
	if transitioning: return
	transitioning = true
	feedback_panel.visible = true
	feedback_label.text = "VOC? MERGULHA NA MATA ESCURA...\nOS ESP?RITOS DA FLORESTA ACORDAM!"
	await get_tree().create_timer(1.8).timeout
	get_tree().change_scene_to_file("res://Scenes/ForestGame.tscn")

func _on_lutar_pressed():
	if transitioning: return
	transitioning = true
	feedback_panel.visible = true
	feedback_label.text = "SUAS FLECHAS REBATEM NAS ARMADURAS DE FERRO!\nA MATA PUXA SEU CORPO PARA QUE VOC? SOBREVIVA..."
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/ForestGame.tscn")

func _on_resgatar_pressed():
	if transitioning: return
	transitioning = true
	feedback_panel.visible = true
	feedback_label.text = "VOC? ESCONDE AS CRIAN?AS NO OCO DA JAQUEIRA SAGRADA E PARTE PARA DESPISTAR OS INVASORES!"
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/ForestGame.tscn")
