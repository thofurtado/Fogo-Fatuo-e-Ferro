extends Control

@onready var player = $Player
@onready var chama_area = $ChamaArea
@onready var ossada_area = $OssadaArea

@onready var dialogue_box = $UILayer/DialogueBox
@onready var dialogue_label = $UILayer/DialogueBox/MarginContainer/VBoxContainer/DialogueText
@onready var speaker_label = $UILayer/DialogueBox/MarginContainer/VBoxContainer/Speaker

@onready var dice_log_panel = $UILayer/DiceLogPanel
@onready var dice_log_text = $UILayer/DiceLogPanel/MarginContainer/DiceLogLabel

@onready var hud_hero_name = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HeroLabel
@onready var hud_hp = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HpLabel
@onready var hud_mana = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/ManaLabel
@onready var inventory_panel = $UILayer/InventoryPanel
@onready var inventory_text = $UILayer/InventoryPanel/MarginContainer/VBoxContainer/ItemListLabel

var near_chama: bool = false
var near_ossada: bool = false
var chama_interacted: bool = false
var ossada_searched: bool = false
var transitioning: bool = false

func _ready():
	dialogue_box.visible = false
	dice_log_panel.visible = false
	inventory_panel.visible = false
	
	chama_area.body_entered.connect(func(b): if b.name == "Player": near_chama = true; _show_hint("CHAMA DO FOGO-F?TUO", "Uma labareda azul espectral flutua sobre o altar de pedra no brejo. Pressione [E] para meditar."))
	chama_area.body_exited.connect(func(b): if b.name == "Player": near_chama = false)
	
	ossada_area.body_entered.connect(func(b): if b.name == "Player": near_ossada = true; _show_hint("RESTOS NA LAMA", "Uma ossada antiga coberta de musgo e armadura enferrujada. Pressione [E] para vasculhar."))
	ossada_area.body_exited.connect(func(b): if b.name == "Player": near_ossada = false)
	
	_update_hud()

func _show_hint(speaker: String, text: String):
	speaker_label.text = speaker
	dialogue_label.text = text
	dialogue_box.visible = true

func _update_hud():
	var arch = GameManager.current_archetype
	hud_hero_name.text = arch["name"]
	hud_hp.text = "? HP: %d/%d" % [arch["vida_atual"], arch["vida_max"]]
	hud_mana.text = "? MANA: %d/%d" % [arch["mana_atual"], arch["mana_max"]]
	_refresh_inventory()

func _refresh_inventory():
	var text = "ITENS NA MOCHILA:
"
	for item in GameManager.inventory:
		text += "? " + item + "
"
	inventory_text.text = text

func _process(_delta):
	if transitioning:
		return
	# Sa?da Sul: Retorna para a Encruzilhada
	if player and player.position.y > 980.0:
		transitioning = true
		get_tree().change_scene_to_file("res://Scenes/Crossroads.tscn")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			inventory_panel.visible = !inventory_panel.visible
			_refresh_inventory()
			
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			if near_chama:
				_interact_chama()
			elif near_ossada and not ossada_searched:
				_interact_ossada()
			elif dialogue_box.visible:
				dialogue_box.visible = false

func _interact_chama():
	var arch = GameManager.current_archetype
	
	if chama_interacted:
		_show_hint("ALTAR M?STICO:", "As chamas azuis sussurram segredos ancestrais em paz. A b?n??o j? foi concedida ao seu esp?rito.")
		return
		
	# Caso 1: Jogador possui o Amuleto de Esmeralda do Curupira
	var has_amulet = false
	for item in GameManager.inventory:
		if "Amuleto" in item or "Esmeralda" in item:
			has_amulet = true
			break
			
	if has_amulet:
		chama_interacted = true
		GameManager.add_item("Centelha de Boitat? (Chama Sagrada)")
		arch["mana_atual"] = min(arch["mana_max"], arch["mana_atual"] + 6)
		arch["vida_atual"] = min(arch["vida_max"], arch["vida_atual"] + 3)
		_update_hud()
		_show_hint("HARMONIA ANCESTRAL:", "O Amuleto de Esmeralda pulsa intensamente! As chamas azuis do brejo envolvem seu corpo com calor espiritual suave. Voc? recuperou Vida e Mana e recebeu a Centelha de Boitat?!")
		return

	# Caso 2: Sem o amuleto, teste de D10 Misticismo
	var pool = max(1, arch["misticismo"])
	var roll = DiceRoller.rolar_teste(pool, 6)
	
	dice_log_panel.visible = true
	var log_str = "? TESTE DE MISTICISMO NO BREJO (D10: %d) ?
Dados: %s | Sucessos: %d | Resultado: %s" % [
		pool, str(roll["dados_rolados"]), roll["sucessos_finais"], roll["resultado_narrativo"].to_upper()
	]
	dice_log_text.text = log_str
	
	chama_interacted = true
	if roll["sucessos_finais"] > 0:
		GameManager.add_item("Centelha de Boitat? (Chama Sagrada)")
		arch["mana_atual"] = min(arch["mana_max"], arch["mana_atual"] + 4)
		_update_hud()
		_show_hint("SUCESSO M?STICO:", "Voc? domina a n?voa com mente firme! O fogo-f?tuo curva-se ? sua vontade. Voc? recebeu a Centelha de Boitat? (+4 Mana)!")
	else:
		arch["vida_atual"] = max(1, arch["vida_atual"] - 2)
		GameManager.add_item("Frasco de N?voa Fria")
		_update_hud()
		_show_hint("CHOQUE ESPIRITUAL:", "O arrepio g?lido da n?voa queima sua carne espiritual (-2 Vida)! Mas voc? aprisiona um pouco da ess?ncia num Frasco de N?voa Fria.")

func _interact_ossada():
	ossada_searched = true
	GameManager.add_item("B?ssola de Lat?o Colonial")
	GameManager.add_item("Bolsa de Moedas Antigas (Dobr?es)")
	_update_hud()
	_show_hint("DESPOJOS DA BANDEIRA:", "Entre as costelas do velho soldado sob a lama, voc? encontra uma B?ssola de Lat?o e Dobr?es coloniais de prata!")
