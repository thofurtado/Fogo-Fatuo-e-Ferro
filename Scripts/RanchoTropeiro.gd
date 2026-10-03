extends Control

@onready var player = $Player
@onready var chest_area = $BauArea
@onready var door_area = $PortaArea
@onready var fire_area = $FogueiraArea

@onready var dialogue_box = $UILayer/DialogueBox
@onready var dialogue_label = $UILayer/DialogueBox/MarginContainer/HBoxContainer/VBoxContainer/DialogueText
@onready var speaker_label = $UILayer/DialogueBox/MarginContainer/HBoxContainer/VBoxContainer/Speaker

@onready var hud_hero_name = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HeroLabel
@onready var hud_hp = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HpLabel
@onready var hud_mana = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/ManaLabel
@onready var inventory_panel = $UILayer/InventoryPanel
@onready var inventory_text = $UILayer/InventoryPanel/MarginContainer/VBoxContainer/ItemListLabel

var near_chest: bool = false
var near_door: bool = false
var near_fire: bool = false
var chest_opened: bool = false
var transitioning: bool = false

func _ready():
	dialogue_box.visible = false
	inventory_panel.visible = false
	
	chest_area.body_entered.connect(func(b): if b.name == "Player": near_chest = true; _show_hint("BAÚ DE CARGA", "Um baú de madeira reforçado com ferro. Pressione [E] para abrir."))
	chest_area.body_exited.connect(func(b): if b.name == "Player": near_chest = false)
	
	door_area.body_entered.connect(func(b): if b.name == "Player": near_door = true; _show_hint("CABANA DE PAU-A-PIQUE", "A porta de tábuas está trancada por dentro com ferrolho. Pressione [E] para bater."))
	door_area.body_exited.connect(func(b): if b.name == "Player": near_door = false)
	
	fire_area.body_entered.connect(func(b): if b.name == "Player": near_fire = true; _show_hint("FOGUEIRA DE POUSO", "Uma panela de ferro com café de milho torrado fumegando. Pressione [E] para se aquecer."))
	fire_area.body_exited.connect(func(b): if b.name == "Player": near_fire = false)
	
	_update_hud()

func _show_hint(speaker: String, text: String):
	speaker_label.text = speaker
	dialogue_label.text = text
	dialogue_box.visible = true

func _update_hud():
	var arch = GameManager.current_archetype
	hud_hero_name.text = arch["name"]
	hud_hp.text = "♥ HP: %d/%d" % [arch["vida_atual"], arch["vida_max"]]
	hud_mana.text = "⚡ MANA: %d/%d" % [arch["mana_atual"], arch["mana_max"]]
	
	if GameManager.current_cargo.has("velocidade_micro"):
		player.speed = 220.0 * GameManager.current_cargo["velocidade_micro"]
		
	_refresh_inventory()

func _refresh_inventory():
	var text = "ITENS NA MOCHILA:\n"
	for item in GameManager.inventory:
		text += "• " + item + "\n"
	if GameManager.current_cargo.has("name"):
		text += "\n📦 CARGA NAS MULAS:\n• " + GameManager.current_cargo["name"]
		text += "\n  (Peso: %s | Marcha: %d%%)" % [GameManager.current_cargo["peso"], int(GameManager.current_cargo["velocidade_micro"] * 100)]
	inventory_text.text = text


func _process(_delta):
	if transitioning:
		return
	# Saída Sul: Retorna para a Encruzilhada
	if player.position.y > 980.0:
		transitioning = true
		get_tree().change_scene_to_file("res://Scenes/Crossroads.tscn")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			inventory_panel.visible = !inventory_panel.visible
			_refresh_inventory()
			
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			if near_chest and not chest_opened:
				chest_opened = true
				GameManager.add_item("Feijão Tropeiro da Serra (+6 HP)")
				GameManager.add_item("Facão de Três Listras (Ferro Forjado)")
				GameManager.add_item("Carta de Rotas Clandestinas da Coroa")
				_update_hud()
				_show_hint("CONTEÚDO DO BAÚ:", "Você encontrou Feijão Tropeiro nutritivo, um Facão de Ferro para abrir mato e uma Carta com o mapa das milícias!")
			elif near_door:
				_show_hint("PORTA DA CABANA:", "Toc-toc... Você ouve alguém resmungar lá dentro: 'Quem tá aí no terreiro? Se for capitão-do-mato, vai levar chumbo grosso!'")
			elif near_fire:
				var arch = GameManager.current_archetype
				arch["vida_atual"] = min(arch["vida_max"], arch["vida_atual"] + 4)
				_update_hud()
				_show_hint("DESCANSO NA FOGUEIRA:", "Você descansa junto às brasas quentes e bebe um gole reconfortante. Recuperou +4 de Vida!")
			elif dialogue_box.visible:
				dialogue_box.visible = false