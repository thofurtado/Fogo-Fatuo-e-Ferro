extends Control

@onready var player = $Player
@onready var sign_area = $PlacaArea
@onready var dialogue_box = $UILayer/DialogueBox
@onready var dialogue_label = $UILayer/DialogueBox/MarginContainer/HBoxContainer/VBoxContainer/DialogueText
@onready var speaker_label = $UILayer/DialogueBox/MarginContainer/HBoxContainer/VBoxContainer/Speaker
@onready var hud_hero_name = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HeroLabel
@onready var hud_hp = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HpLabel
@onready var hud_mana = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/ManaLabel
@onready var inventory_panel = $UILayer/InventoryPanel
@onready var inventory_text = $UILayer/InventoryPanel/MarginContainer/VBoxContainer/ItemListLabel

var near_sign: bool = false
var transitioning: bool = false

func _ready():
	dialogue_box.visible = false
	inventory_panel.visible = false
	sign_area.body_entered.connect(_on_sign_entered)
	sign_area.body_exited.connect(_on_sign_exited)
	_update_hud()

func _update_hud():
	var arch = GameManager.current_archetype
	hud_hero_name.text = arch["name"]
	hud_hp.text = "♥ HP: %d/%d" % [arch["vida_atual"], arch["vida_max"]]
	hud_mana.text = "⚡ MANA: %d/%d" % [arch["mana_atual"], arch["mana_max"]]
	_refresh_inventory()

func _refresh_inventory():
	var text = "ITENS NA MOCHILA:\n"
	for item in GameManager.inventory:
		text += "• " + item + "\n"
	inventory_text.text = text

func _process(_delta):
	if transitioning:
		return
		
	# Saída Noroeste: Rancho dos Tropeiros
	if player.position.x < 90.0 and player.position.y < 300.0:
		transitioning = true
		get_tree().change_scene_to_file("res://Scenes/RanchoTropeiro.tscn")
		
	# Saída Nordeste: Brejo do Fogo-Fátuo
	elif player.position.x > 480.0 and player.position.y < 300.0:
		transitioning = true
		get_tree().change_scene_to_file("res://Scenes/BrejoFogoFatuo.tscn")
		
	# Saída Sul: Retorna para a Clareira
	elif player.position.y > 980.0:
		transitioning = true
		get_tree().change_scene_to_file("res://Scenes/ForestGame.tscn")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			inventory_panel.visible = !inventory_panel.visible
			_refresh_inventory()
			
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			if near_sign:
				speaker_label.text = "PLACA DE MADEIRA RÚSTICA:"
				dialogue_label.text = "◄ ESQUERDA: Rancho dos Tropeiros & Pouso da Serra\n► DIREITA: Brejo do Fogo-Fátuo & Altar Ancestral\n▼ SUL: Retorno para a Clareira Sagrada"
				dialogue_box.visible = !dialogue_box.visible
			elif dialogue_box.visible:
				dialogue_box.visible = false

func _on_sign_entered(body):
	if body.name == "Player":
		near_sign = true
		speaker_label.text = "ENCRUZILHADA DA SERRA:"
		dialogue_label.text = "Uma placa entalhada à faca marca os caminhos. Pressione [E] para ler."
		dialogue_box.visible = true

func _on_sign_exited(body):
	if body.name == "Player":
		near_sign = false