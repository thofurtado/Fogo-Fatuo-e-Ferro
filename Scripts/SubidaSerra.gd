extends Node2D

@onready var player = $YSortContainer/Player
@onready var mula = $YSortContainer/MulaBonita

@onready var hud_hero_name = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HeroLabel
@onready var hud_hp = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HpLabel
@onready var hud_affinity = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/AffinityLabel
@onready var hud_cargo = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/CargoLabel

@onready var dialogue_box = $UILayer/DialogueBox
@onready var dialogue_speaker = $UILayer/DialogueBox/MarginContainer/VBoxContainer/Speaker
@onready var dialogue_text = $UILayer/DialogueBox/MarginContainer/VBoxContainer/DialogueText

@onready var inventory_panel = $UILayer/InventoryPanel
@onready var inventory_text = $UILayer/InventoryPanel/MarginContainer/VBoxContainer/ItemListLabel

var current_interactable = null
var chest_opened: bool = false
var caipora_offering_done: bool = false

func _ready():
	dialogue_box.visible = false
	inventory_panel.visible = false
	
	# Garante que a comitiva do Tropeiro está ativa
	GameManager.select_archetype_by_id("tropeiro")
	_update_hud()
	
	# Diálogo inicial de chegada à subida
	_show_dialogue("SUBIDA DA SERRA DE PARANAPIACABA (1645)", "O ar da serra é úmido e cheira a terra molhada. Diante de você ergue-se o paredão monumental da Serra do Mar. A mulinha Bonita bufa ao seu lado, atenta à trilha de lama. [WASD: Andar | E: Interagir | I: Inventário]")

	# Conexões das áreas de interação
	$YSortContainer/RanchoFogueira.body_entered.connect(func(b): if b == player: register_target("fogueira_rancho", "FOGUEIRA DE POUSO", "Brasas quentes de café de milho. Pressione [E] para descansar e tratar a mula."))
	$YSortContainer/RanchoFogueira.body_exited.connect(func(b): if b == player: unregister_target("fogueira_rancho"))

	$YSortContainer/RanchoBau.body_entered.connect(func(b): if b == player: register_target("bau_rancho", "BAÚ DO RANCHO", "Baú reforçado de ferro. Pressione [E] para abrir."))
	$YSortContainer/RanchoBau.body_exited.connect(func(b): if b == player: unregister_target("bau_rancho"))

	$YSortContainer/PlacaGarganta.body_entered.connect(func(b): if b == player: register_target("placa_garganta", "MARCO DE MADEIRA", "Placa antiga de trilha. Pressione [E] para ler."))
	$YSortContainer/PlacaGarganta.body_exited.connect(func(b): if b == player: unregister_target("placa_garganta"))

	$YSortContainer/AltarCaipora.body_entered.connect(func(b): if b == player: register_target("altar_caipora", "ALTAR DO BAMBUZAL", "Tronco e pedras rituais da Caipora. Pressione [E] para deixar oferenda de Fumo."))
	$YSortContainer/AltarCaipora.body_exited.connect(func(b): if b == player: unregister_target("altar_caipora"))

	$YSortContainer/CruzeiroTopo.body_entered.connect(func(b): if b == player: register_target("cruzeiro_topo", "A GRANDE ENCRUZILHADA", "Cruzeiro de pedra no cume da serra. Pressione [E] para contemplar o Planalto."))
	$YSortContainer/CruzeiroTopo.body_exited.connect(func(b): if b == player: unregister_target("cruzeiro_topo"))

func _process(_delta):
	# Se apertar E ou Espaço e tiver interação pendente
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_E):
		_handle_interaction()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			inventory_panel.visible = !inventory_panel.visible
			_refresh_inventory()
		elif event.keycode == KEY_ESCAPE or event.keycode == KEY_SPACE:
			if dialogue_box.visible:
				dialogue_box.visible = false

func _update_hud():
	var arch = GameManager.current_archetype
	hud_hero_name.text = "🤠 " + arch["name"]
	hud_hp.text = "♥ HP: %d/%d" % [arch["vida_atual"], arch["vida_max"]]
	
	var aff = mula.affinity if mula else 100
	var status = "Dócil"
	if aff >= 120:
		status = "Irmã de Alma"
	elif aff < 50:
		status = "Arredia"
	hud_affinity.text = "🐴 Mula: %d%% [%s]" % [aff, status]
	
	if GameManager.current_cargo.has("name"):
		hud_cargo.text = "📦 " + GameManager.current_cargo["name"]
	else:
		hud_cargo.text = "📦 Carga: Fardo de Sal & Charque"

func _refresh_inventory():
	var text = "🎒 ITENS NA ALGIBEIRA:\n"
	for item in GameManager.inventory:
		text += " • " + item + "\n"
	if GameManager.current_cargo.has("name"):
		text += "\n🐴 CARGA NAS BRUACAS DA MULA:\n • " + GameManager.current_cargo["name"]
		text += "\n   (Peso: %s | Marcha da Tropa: %d%%)" % [GameManager.current_cargo["peso"], int(GameManager.current_cargo["velocidade_micro"] * 100)]
	inventory_text.text = text

func _show_dialogue(speaker: String, text: String):
	dialogue_speaker.text = speaker
	dialogue_text.text = text
	dialogue_box.visible = true

func register_target(id: String, speaker: String, text: String):
	current_interactable = {"id": id, "speaker": speaker, "text": text}
	_show_dialogue(speaker, text)

func unregister_target(id: String):
	if current_interactable and current_interactable["id"] == id:
		current_interactable = null
		dialogue_box.visible = false

func _handle_interaction():
	if not current_interactable:
		if dialogue_box.visible:
			dialogue_box.visible = false
		return
		
	var id = current_interactable["id"]
	match id:
		"bau_rancho":
			if not chest_opened:
				chest_opened = true
				GameManager.add_item("Feijão Tropeiro Nutritivo (+6 HP)")
				GameManager.add_item("Facão de Três Listras (Aço Forjado)")
				GameManager.add_item("Fumo de Rolo de Oferenda")
				mula.add_affinity(10)
				_update_hud()
				_show_dialogue("BAÚ DO RANCHO:", "Você recolheu rações de Feijão Tropeiro, um Facão de trilha e Fumo de Rolo perfumado! A mula Bonita agradece a fartura (+10% Afinidade).")
			else:
				_show_dialogue("BAÚ DO RANCHO:", "O baú de ferro está vazio.")
		"fogueira_rancho":
			var arch = GameManager.current_archetype
			arch["vida_atual"] = arch["vida_max"]
			mula.add_affinity(15)
			_update_hud()
			_show_dialogue("FOGUEIRA DE POUSO:", "Você bebe um café de milho quente e faz carinho nas orelhas da Bonita junto às brasas. Vida restaurada ao máximo e a mula descansou (+15% Afinidade)!")
		"placa_garganta":
			_show_dialogue("MARCO DA GARGANTA DAS ÁGUAS:", "« Cuidado viajante: A cachoeira esculpiu abismos nas pedras. Empurre os barris de cascalho para firmar a passagem sobre as poças de barro! »")
		"altar_caipora":
			if not caipora_offering_done:
				caipora_offering_done = true
				mula.add_affinity(25)
				_update_hud()
				_show_dialogue("O BAMBUZAL DA CAIPORA:", "Você deposita o naco de fumo de rolo na forquilha da árvore. Um redemoinho de folhas perfumadas sobe pelo ar e um assobio brando ecoa na serra... A dona da mata abençoou sua tropa! (+25% Afinidade).")
			else:
				_show_dialogue("ALTAR DA CAIPORA:", "As cinzas de fumo aromático repousam em paz. A floresta está calma e a passagem está aberta.")
		"cruzeiro_topo":
			_show_dialogue("A GRANDE ENCRUZILHADA DA SERRA:", "Você superou a subida de Paranapiacaba! Diante de você abre-se o Planalto de Piratininga. As rotas dos tropeiros, batedores e desertores se cruzam sob o olhar do Fogo-Fátuo...")
