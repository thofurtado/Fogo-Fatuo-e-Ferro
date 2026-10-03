extends Control

@onready var title_label = $MainContainer/HeaderPanel/VBoxContainer/TitleLabel
@onready var subtitle_label = $MainContainer/HeaderPanel/VBoxContainer/SubtitleLabel
@onready var desc_label = $MainContainer/InfoPanel/MarginContainer/VBoxContainer/DescLabel
@onready var stats_label = $MainContainer/InfoPanel/MarginContainer/VBoxContainer/StatsLabel
@onready var passive_label = $MainContainer/InfoPanel/MarginContainer/VBoxContainer/PassiveLabel
@onready var item_label = $MainContainer/InfoPanel/MarginContainer/VBoxContainer/ItemLabel

@onready var btn_prev = $MainContainer/NavContainer/BtnPrev
@onready var btn_next = $MainContainer/NavContainer/BtnNext
@onready var counter_label = $MainContainer/NavContainer/CounterLabel
@onready var btn_confirm = $MainContainer/BtnConfirm
@onready var btn_back = $BtnBack

var current_idx: int = 0

func _ready():
	btn_prev.pressed.connect(_on_prev)
	btn_next.pressed.connect(_on_next)
	btn_confirm.pressed.connect(_on_confirm)
	btn_back.pressed.connect(_on_back)
	_update_display()

func _update_display():
	var arch = GameManager.archetypes_catalog[current_idx]
	title_label.text = arch["name"].to_upper()
	subtitle_label.text = arch["title"]
	desc_label.text = arch["desc"]
	
	stats_label.text = "FORÇA: %d  |  DESTREZA: %d  |  LÁBIA: %d  |  MISTICISMO: %d\nVIDA MÁXIMA: %d   •   MANA: %d" % [
		arch["forca"], arch["destreza"], arch["labia"], arch["misticismo"],
		arch["vida_max"], arch["mana_max"]
	]
	
	passive_label.text = "✦ PASSIVA: " + arch["passive"]
	item_label.text = "🎒 ITEM INICIAL: " + arch["initial_item"]
	counter_label.text = "%d / %d" % [current_idx + 1, GameManager.archetypes_catalog.size()]

func _on_prev():
	current_idx = (current_idx - 1 + GameManager.archetypes_catalog.size()) % GameManager.archetypes_catalog.size()
	_update_display()

func _on_next():
	current_idx = (current_idx + 1) % GameManager.archetypes_catalog.size()
	_update_display()

func _on_confirm():
	GameManager.select_archetype(current_idx)
	if GameManager.current_archetype["id"] == "tropeiro":
		get_tree().change_scene_to_file("res://Scenes/PrologoTropeiro.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/WorldRPG.tscn")


func _on_back():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")