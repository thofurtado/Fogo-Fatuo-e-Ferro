extends Node2D

@onready var player = $YSortContainer/Player
@onready var mula = $YSortContainer/MulaBonita
@onready var mula_inimiga: MulaSemCabecaController = $YSortContainer/MulaSemCabeca
@onready var combat_system: CombatSystem = $CombatSystem

@onready var hud_hero_name = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HeroLabel
@onready var hud_hp = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HpLabel
@onready var hud_affinity = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/AffinityLabel
@onready var hud_cargo = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/CargoLabel

@onready var dialogue_box = $UILayer/DialogueBox
@onready var dialogue_speaker = $UILayer/DialogueBox/MarginContainer/VBoxContainer/Speaker
@onready var dialogue_text = $UILayer/DialogueBox/MarginContainer/VBoxContainer/DialogueText

@onready var inventory_panel = $UILayer/InventoryPanel
@onready var inventory_text = $UILayer/InventoryPanel/MarginContainer/VBoxContainer/ItemListLabel
@onready var combat_hud = $UILayer/CombatHUD
@onready var enemy_health_label = $UILayer/CombatHUD/MarginContainer/VBoxContainer/EnemyHealth
@onready var enemy_state_label = $UILayer/CombatHUD/MarginContainer/VBoxContainer/EnemyState
@onready var combat_message_label = $UILayer/CombatHUD/MarginContainer/VBoxContainer/CombatMessage

var current_interactable = null
var chest_opened: bool = false
var waterfall_chest_opened: bool = false
var caipora_offering_done: bool = false

func _ready():
	dialogue_box.visible = false
	inventory_panel.visible = false
	
	# Garante que a comitiva do Tropeiro está ativa (se não veio pelo prólogo)
	if GameManager.current_archetype.is_empty():
		GameManager.select_archetype_by_id("tropeiro")
	if player.has_method("refresh_health_from_game_manager"):
		player.refresh_health_from_game_manager()
	_update_hud()
	combat_hud.visible = false
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	mula_inimiga.health_changed.connect(_on_enemy_health_changed)
	mula_inimiga.state_changed.connect(_on_enemy_state_changed)
	mula_inimiga.defeated.connect(_on_enemy_defeated)
	combat_system.attack_applied.connect(_on_combat_attack_applied)
	if player.current_health <= 0:
		_on_player_died()
	_refresh_combat_hud()
	
	# Iluminação e clima atmosférico conforme escolha na Estalagem (Noite x Alvorada)
	var modulate_node = CanvasModulate.new()
	if GameManager.periodo_partida == "noite":
		modulate_node.color = Color(0.42, 0.48, 0.75, 1.0) # Luz noturna azulada
		add_child(modulate_node)
		_show_dialogue("SUBIDA DA SERRA — PARTIDA NOTURNA (1645)", "A noite serasteira envolve a mata em trevas e névoa densa. Apenas as tochas e o luar prateado revelam os contornos das pedras. A mulinha Bonita bufa atenta com as orelhas em pé, farejando os assobios na escuridão. [WASD: Andar | E: Interagir | I: Inventário]")
	else:
		modulate_node.color = Color(1.0, 0.98, 0.92, 1.0) # Luz límpida da manhã
		add_child(modulate_node)
		_show_dialogue("SUBIDA DA SERRA — PARTIDA NA ALVORADA (1645)", "A claridade da manhã dissipa a neblina do litoral. Diante de você, o paredão colossal da Serra do Mar e a subida de Paranapiacaba estão visíveis e límpidos. A mulinha Bonita segue firme na trilha! [WASD: Andar | E: Interagir | I: Inventário]")

	# Conexões das áreas de interação
	$YSortContainer/RanchoFogueira.body_entered.connect(func(b): if b == player: register_target("fogueira_rancho", "FOGUEIRA DE POUSO", "Brasas quentes de café de milho. Pressione [E] para descansar e tratar a mula."))
	$YSortContainer/RanchoFogueira.body_exited.connect(func(b): if b == player: unregister_target("fogueira_rancho"))

	$YSortContainer/RanchoBau.body_entered.connect(func(b): if b == player: register_target("bau_rancho", "BAÚ DO RANCHO", "Baú reforçado de ferro. Pressione [E] para abrir."))
	$YSortContainer/RanchoBau.body_exited.connect(func(b): if b == player: unregister_target("bau_rancho"))

	$YSortContainer/PlacaGarganta.body_entered.connect(func(b): if b == player: register_target("placa_garganta", "MARCO DE MADEIRA", "Placa antiga de trilha. Pressione [E] para ler."))
	$YSortContainer/PlacaGarganta.body_exited.connect(func(b): if b == player: unregister_target("placa_garganta"))

	if $YSortContainer.has_node("BauCachoeira"):
		$YSortContainer/BauCachoeira.body_entered.connect(func(b): if b == player: register_target("bau_cachoeira", "QUEDA D'ÁGUA DA CACHOEIRA DO VÉU", "O estrondo da água espirra neblina nas pedras. Pressione [E] para inspecionar as fendas."))
		$YSortContainer/BauCachoeira.body_exited.connect(func(b): if b == player: unregister_target("bau_cachoeira"))

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
		elif event.keycode == KEY_R and player.current_health <= 0:
			var arch = GameManager.current_archetype
			arch["vida_atual"] = arch["vida_max"]
			GameManager.current_archetype = arch
			get_tree().reload_current_scene()
		elif event.keycode == KEY_ESCAPE or event.keycode == KEY_SPACE:
			if dialogue_box.visible:
				dialogue_box.visible = false

func _update_hud():
	var arch = GameManager.current_archetype
	hud_hero_name.text = "🤠 " + arch["name"]
	var player_hp: int = player.current_health if player and "current_health" in player else int(arch["vida_atual"])
	var player_max_hp: int = player.max_health if player and "max_health" in player else int(arch["vida_max"])
	hud_hp.text = "♥ HP: %d/%d" % [player_hp, player_max_hp]
	
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

func _on_player_health_changed(_current: int, _maximum: int):
	_update_hud()

func _on_player_died():
	combat_hud.visible = true
	combat_message_label.text = "O Tropeiro caiu. Pressione R para recomeçar."

func _on_enemy_health_changed(_current: int, _maximum: int):
	_refresh_combat_hud()

func _on_enemy_state_changed(_previous_state: int, _new_state: int):
	_refresh_combat_hud()
	if mula_inimiga.get_state_name() == "WINDUP":
		combat_message_label.text = "A Mula sem Cabeça prepara a investida!"

func _on_enemy_defeated(_enemy: Node2D):
	combat_hud.visible = true
	combat_message_label.text = "A Mula sem Cabeça foi derrotada."

func _on_combat_attack_applied(attacker: Node, target: Node2D, damage: int):
	combat_hud.visible = true
	var attacker_name := "Tropeiro" if attacker == player else "Mula sem Cabeça"
	var target_name := "Mula sem Cabeça" if target == mula_inimiga else "Tropeiro"
	combat_message_label.text = "%s acertou %s: %d de dano." % [attacker_name, target_name, damage]

func _refresh_combat_hud():
	if not is_instance_valid(mula_inimiga):
		return
	enemy_health_label.text = "MULA SEM CABEÇA  —  HP %d/%d" % [mula_inimiga.health, mula_inimiga.max_health]
	enemy_state_label.text = "Estado: %s" % mula_inimiga.get_state_name()
	combat_hud.visible = mula_inimiga.get_state_name() != "IDLE" or mula_inimiga.health < mula_inimiga.max_health

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
			player.refresh_health_from_game_manager()
			mula.add_affinity(15)
			_update_hud()
			_show_dialogue("FOGUEIRA DE POUSO:", "Você bebe um café de milho quente e faz carinho nas orelhas da Bonita junto às brasas. Vida restaurada ao máximo e a mula descansou (+15% Afinidade)!")
		"placa_garganta":
			_show_dialogue("MARCO DA GARGANTA DAS ÁGUAS:", "« Cuidado viajante: A cachoeira esculpiu abismos nas pedras. Empurre os barris de cascalho para firmar a passagem sobre as poças de barro! »")
		"bau_cachoeira":
			if GameManager.boato_cachoeira_descoberto:
				if not waterfall_chest_opened:
					waterfall_chest_opened = true
					GameManager.add_item("40 Patacas de Prata Jesuítas")
					GameManager.add_item("Terço de Jacarandá Sagrado")
					mula.add_affinity(20)
					_update_hud()
					_show_dialogue("BAÚ DA CACHOEIRA DO VÉU (BOATO CONFIRMADO!):", "Lembrando-se do segredo sussurrado na taverna de Santos, você enfia os braços nas fendas escuras atrás da cascata... e puxa o velho baú de ferro! Você encontrou 40 Patacas de Prata e um Terço de Jacarandá! (+20% Afinidade da Mula).")
				else:
					_show_dialogue("CACHOEIRA DO VÉU:", "A fenda atrás das pedras está vazia. Você já resgatou o tesouro do bandeirante.")
			else:
				_show_dialogue("CACHOEIRA DO VÉU:", "A água desce ruidosa e gelada pelas pedras escorregadias. Parece haver fendas profundas na rocha úmida, mas sem saber o que procurar, é perigoso colocar as mãos.")
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

func on_player_fell_ledge(hp_loss: int, aff_loss: int):
	if mula:
		mula.add_affinity(-aff_loss)
	if player and player.has_method("refresh_health_from_game_manager"):
		player.refresh_health_from_game_manager()
	_update_hud()
	_show_dialogue("⚠️ QUEDA NA ESCARPA!", "Você escorregou pelo despenhadeiro de pedra da serra! Cascalho e poeira voaram morro abaixo. A mula Bonita relinchou sobressaltada com o salto abrupto! (-%d HP | -%d%% Afinidade da Mula). Cuidado com o barranco: siga as curvas calçadas da trilha para subir em segurança!" % [hp_loss, aff_loss])
