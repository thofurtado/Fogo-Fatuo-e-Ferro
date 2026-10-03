extends Control

@onready var bg_dia = $BackgroundDia
@onready var bg_noite = $BackgroundNoite
@onready var player = $Player
@onready var amuleto_area = $AmuletoArea
@onready var curupira_area = $CurupiraArea
@onready var dialogue_box = $UILayer/DialogueBox
@onready var dialogue_label = $UILayer/DialogueBox/MarginContainer/HBoxContainer/VBoxContainer/DialogueText
@onready var speaker_label = $UILayer/DialogueBox/MarginContainer/HBoxContainer/VBoxContainer/Speaker
@onready var dice_log_panel = $UILayer/DiceLogPanel
@onready var dice_log_text = $UILayer/DiceLogPanel/MarginContainer/DiceLogLabel
@onready var inventory_panel = $UILayer/InventoryPanel
@onready var inventory_text = $UILayer/InventoryPanel/MarginContainer/VBoxContainer/ItemListLabel
@onready var hero_name_label = $UILayer/InventoryPanel/MarginContainer/VBoxContainer/HeroNameLabel

# Top HUD
@onready var hud_hero_name = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HeroLabel
@onready var hud_hp = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HpLabel
@onready var hud_mana = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/ManaLabel
@onready var day_night_label = $UILayer/TopHUD/MarginContainer/VBoxContainer/DayNightNotice

var is_night: bool = false
var near_amulet: bool = false
var near_curupira: bool = false
var amulet_collected: bool = false
var transitioning: bool = false

func _ready():
	bg_noite.modulate.a = 0.0
	dialogue_box.visible = false
	dice_log_panel.visible = false
	inventory_panel.visible = false
	
	amuleto_area.body_entered.connect(_on_amulet_entered)
	amuleto_area.body_exited.connect(_on_amulet_exited)
	
	curupira_area.body_entered.connect(_on_curupira_entered)
	curupira_area.body_exited.connect(_on_curupira_exited)
	
	_update_hud()

func _update_hud():
	var arch = GameManager.current_archetype
	hud_hero_name.text = arch["name"]
	hud_hp.text = "♥ HP: %d/%d" % [arch["vida_atual"], arch["vida_max"]]
	hud_mana.text = "⚡ MANA: %d/%d" % [arch["mana_atual"], arch["mana_max"]]
	
	hero_name_label.text = arch["name"].to_upper() + " (" + arch["title"] + ")"
	_refresh_inventory()

func _refresh_inventory():
	var text = "ITENS NA MOCHILA:\n"
	for item in GameManager.inventory:
		text += "• " + item + "\n"
	inventory_text.text = text

func _process(delta):
	var target_alpha = 1.0 if is_night else 0.0
	bg_noite.modulate.a = lerp(bg_noite.modulate.a, target_alpha, delta * 3.5)
	
	# Transição ao norte da trilha (para a Encruzilhada)
	if not transitioning and player.position.y < 130.0:
		transitioning = true
		get_tree().change_scene_to_file("res://Scenes/Crossroads.tscn")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_N:
			is_night = !is_night
			if is_night:
				day_night_label.text = "NOITE (Bioluminescência Ativa & Presença do Curupira)"
				day_night_label.modulate = Color(0.4, 0.85, 1.0)
			else:
				day_night_label.text = "DIA (Sol na Copa & Trilha Clara)"
				day_night_label.modulate = Color(1.0, 0.9, 0.5)

		# Abrir/Fechar Inventário
		if event.keycode == KEY_I:
			inventory_panel.visible = !inventory_panel.visible
			_refresh_inventory()

		# Interagir
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			if near_amulet and not amulet_collected:
				_interact_amulet()
			elif near_curupira:
				_interact_curupira()
			elif dialogue_box.visible:
				dialogue_box.visible = false

func _interact_amulet():
	amulet_collected = true
	$AmuletoArea/Sprite2D.visible = false
	GameManager.add_item("Amuleto Esmeralda do Curupira")
	_update_hud()
	
	speaker_label.text = "AMULETO ANCESTRAL:"
	dialogue_label.text = "Você recolhe o Amuleto de Esmeralda! Ele pulsa com calor da terra. Siga a trilha ao NORTE para a Encruzilhada!"
	dialogue_box.visible = true

func _interact_curupira():
	speaker_label.text = "O CURUPIRA (O Guardião dos Pés Invertidos):"
	var arch = GameManager.current_archetype
	var pool = max(1, arch["misticismo"])
	
	# Rola teste de dados do DiceRoller.gd!
	var roll = DiceRoller.rolar_teste(pool, 6)
	
	dice_log_panel.visible = true
	var log_str = "✦ TESTE DE MISTICISMO (Parada de D10: %d) ✦\nDados: %s | Sucessos: %d | Resultado: %s" % [
		pool, str(roll["dados_rolados"]), roll["sucessos_finais"], roll["resultado_narrativo"].to_upper()
	]
	dice_log_text.text = log_str
	
	if roll["sucessos_finais"] > 0:
		dialogue_label.text = "'Vejo que seu coração respeita a mata, %s! Siga ao norte até a bifurcação. O Rancho dos Tropeiros guarda ferro, mas o Brejo guarda o fogo sagrado.'" % arch["name"]
	else:
		dialogue_label.text = "'Hihihi! Quem pisa na minha floresta sem oferenda perde o rumo das pegadas!' (Você sente uma tontura mágica nas pernas!)"
		
	dialogue_box.visible = true

func _on_amulet_entered(body):
	if body.name == "Player" and not amulet_collected:
		near_amulet = true
		speaker_label.text = "INDÍCIO NA TRILHA:"
		dialogue_label.text = "Há algo brilhando entre as raízes... Pressione [E] para pegar."
		dialogue_box.visible = true

func _on_amulet_exited(body):
	if body.name == "Player":
		near_amulet = false

func _on_curupira_entered(body):
	if body.name == "Player":
		near_curupira = true
		speaker_label.text = "PRESENÇA NA COPA:"
		dialogue_label.text = "Você sente olhos espiando de trás do grande tronco... Pressione [E] para interagir."
		dialogue_box.visible = true

func _on_curupira_exited(body):
	if body.name == "Player":
		near_curupira = false