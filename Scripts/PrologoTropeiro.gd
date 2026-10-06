extends Control

# ==============================================================================
# PRÓLOGO INTERATIVO DO TROPEIRO (1645) — HISTÓRIA EM QUADRINHOS & ROLAGEM
# ==============================================================================
# Sequência narrativa no estilo Xilogravura / Quadrinhos de Flávio Colin:
# - Página 1: O Cais de Santos (1645) e a mulinha Bonita
# - Página 2: A Taverna do Pescador Torto e o aviso de Mestre Bento
# - Página 3: Teste de Percepção (Instinto 3 + Navegação 5 = 8 D10s) na Bandeja
#   * Falha / Ruim (<= 0): Contrabandista de Pólvora & Ferro (Mais complicações)
#   * Bom Resultado (1-2): Capataz da Fazenda Real / Sal & Charque (Carga mais segura)
#   * Sucesso Absoluto (3+): Padre Jesuíta / Fumo & Relíquias + BOATO DA CACHOEIRA!
# ==============================================================================

enum Stage {
	PAGE_1_CAIS,
	PAGE_2_TAVERNA,
	PAGE_3_DICE_ROLL,
	PAGE_4_ESTALAGEM
}

var current_stage: Stage = Stage.PAGE_1_CAIS
var selected_cargo_id: String = "sal_charque"

# Texturas das Páginas de Quadrinhos
const TEX_PAGE_1 = preload("res://Assets/Backgrounds/tropeiro_intro_p01.jpg")
const TEX_PAGE_2 = preload("res://Assets/Backgrounds/tropeiro_intro_p02.jpg")
const TEX_PAGE_3 = preload("res://Assets/Backgrounds/tropeiro_intro_p03.jpg")
const TEX_PAGE_4 = preload("res://Assets/Backgrounds/tropeiro_intro_p04.jpg")

# Nós da UI
@onready var bg_rect: TextureRect = $BackgroundHQ
@onready var fade_overlay: ColorRect = $UILayer/FadeOverlay

@onready var page1_container: PanelContainer = $UILayer/Page1Container
@onready var btn_page1_next: Button = $UILayer/Page1Container/Margin/VBox/BtnPage1Next

@onready var page2_container: PanelContainer = $UILayer/Page2Container
@onready var btn_page2_next: Button = $UILayer/Page2Container/Margin/VBox/BtnPage2Next

@onready var page3_container: Control = $UILayer/Page3DiceContainer
@onready var dice_tray = $UILayer/Page3DiceContainer/DiceTray
@onready var btn_roll_dice: Button = $UILayer/Page3DiceContainer/RollButtonContainer/BtnRollDice

@onready var revelation_panel: PanelContainer = $UILayer/Page3DiceContainer/RevelationPanel
@onready var outcome_badge: Label = $UILayer/Page3DiceContainer/RevelationPanel/Margin/VBox/OutcomeBadge
@onready var outcome_narrative: Label = $UILayer/Page3DiceContainer/RevelationPanel/Margin/VBox/OutcomeNarrative
@onready var rumor_box: PanelContainer = $UILayer/Page3DiceContainer/RevelationPanel/Margin/VBox/RumorBox
@onready var rumor_text: Label = $UILayer/Page3DiceContainer/RevelationPanel/Margin/VBox/RumorBox/RumorMargin/RumorText

@onready var tab_sal: Button = $UILayer/Page3DiceContainer/RevelationPanel/Margin/VBox/CargoTabs/TabSal
@onready var tab_ferro: Button = $UILayer/Page3DiceContainer/RevelationPanel/Margin/VBox/CargoTabs/TabFerro
@onready var tab_fumo: Button = $UILayer/Page3DiceContainer/RevelationPanel/Margin/VBox/CargoTabs/TabFumo

@onready var cargo_title: Label = $UILayer/Page3DiceContainer/RevelationPanel/Margin/VBox/CargoCard/CargoMargin/CargoVBox/CargoTitle
@onready var cargo_stats: Label = $UILayer/Page3DiceContainer/RevelationPanel/Margin/VBox/CargoCard/CargoMargin/CargoVBox/CargoStats
@onready var cargo_desc: Label = $UILayer/Page3DiceContainer/RevelationPanel/Margin/VBox/CargoCard/CargoMargin/CargoVBox/CargoDesc
@onready var btn_start_journey: Button = $UILayer/Page3DiceContainer/RevelationPanel/Margin/VBox/BtnStartJourney

# Nós da Página 4 (Estalagem & Exploração Urbana)
@onready var page4_container: PanelContainer = $UILayer/Page4EstalagemContainer
@onready var cargo_badge_estalagem: Label = $UILayer/Page4EstalagemContainer/Margin/VBox/CargoBadge
@onready var btn_partir_noite: Button = $UILayer/Page4EstalagemContainer/Margin/VBox/ActionButtons/BtnPartirNoite
@onready var btn_partir_dia: Button = $UILayer/Page4EstalagemContainer/Margin/VBox/ActionButtons/BtnPartirDia
@onready var btn_explorar_cidade: Button = $UILayer/Page4EstalagemContainer/Margin/VBox/ActionButtons/BtnExplorarCidade

@onready var city_modal: PanelContainer = $UILayer/CityExplorationModal
@onready var modal_feedback: Label = $UILayer/CityExplorationModal/ModalMargin/ModalVBox/ModalFeedback
@onready var btn_visit_store: Button = $UILayer/CityExplorationModal/ModalMargin/ModalVBox/ModalButtons/BtnVisitStore
@onready var btn_visit_square: Button = $UILayer/CityExplorationModal/ModalMargin/ModalVBox/ModalButtons/BtnVisitSquare
@onready var btn_return_estalagem: Button = $UILayer/CityExplorationModal/ModalMargin/ModalVBox/ModalButtons/BtnReturnEstalagem

func _ready():
	# Assegura que o Tropeiro está selecionado
	GameManager.select_archetype_by_id("tropeiro")
	
	fade_overlay.visible = false
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.color = Color(0, 0, 0, 0)
	
	# Conexões de botões
	btn_page1_next.pressed.connect(_on_page1_next)
	btn_page2_next.pressed.connect(_on_page2_next)
	btn_roll_dice.pressed.connect(_on_roll_dice_pressed)
	
	dice_tray.roll_completed.connect(_on_dice_roll_completed)
	
	tab_sal.pressed.connect(func(): _select_cargo("sal_charque"))
	tab_ferro.pressed.connect(func(): _select_cargo("ferro_polvora"))
	tab_fumo.pressed.connect(func(): _select_cargo("fumo_reliquias"))
	
	btn_start_journey.pressed.connect(_on_start_journey_pressed)
	
	# Conexões da Página 4 (Estalagem & Exploração)
	btn_partir_noite.pressed.connect(_on_partir_noite_pressed)
	btn_partir_dia.pressed.connect(_on_partir_dia_pressed)
	btn_explorar_cidade.pressed.connect(_on_explorar_cidade_pressed)
	
	btn_visit_store.pressed.connect(_on_visit_store_pressed)
	btn_visit_square.pressed.connect(_on_visit_square_pressed)
	btn_return_estalagem.pressed.connect(_on_return_estalagem_pressed)
	
	# Inicializa na Página 1
	_go_to_stage(Stage.PAGE_1_CAIS)

func _go_to_stage(target_stage: Stage):
	current_stage = target_stage
	
	match current_stage:
		Stage.PAGE_1_CAIS:
			bg_rect.texture = TEX_PAGE_1
			page1_container.visible = true
			page2_container.visible = false
			page3_container.visible = false
			page4_container.visible = false
			city_modal.visible = false
		Stage.PAGE_2_TAVERNA:
			bg_rect.texture = TEX_PAGE_2
			page1_container.visible = false
			page2_container.visible = true
			page3_container.visible = false
			page4_container.visible = false
			city_modal.visible = false
		Stage.PAGE_3_DICE_ROLL:
			bg_rect.texture = TEX_PAGE_3
			page1_container.visible = false
			page2_container.visible = false
			page3_container.visible = true
			page4_container.visible = false
			city_modal.visible = false
			revelation_panel.visible = false
			btn_roll_dice.visible = true
			btn_roll_dice.disabled = false
			dice_tray.setup_dice(8)
		Stage.PAGE_4_ESTALAGEM:
			bg_rect.texture = TEX_PAGE_4
			page1_container.visible = false
			page2_container.visible = false
			page3_container.visible = false
			page4_container.visible = true
			city_modal.visible = false
			var cargo = GameManager.cargos_catalog[selected_cargo_id]
			cargo_badge_estalagem.text = "📦 Carga Pronta: %s (%s) — Pagamento: %d Réis" % [cargo["name"], cargo["category"], cargo["lucro_reis"]]

func _on_page1_next():
	_fade_transition(func():
		_go_to_stage(Stage.PAGE_2_TAVERNA)
	)

func _on_page2_next():
	_fade_transition(func():
		_go_to_stage(Stage.PAGE_3_DICE_ROLL)
	)

func _fade_transition(callback: Callable):
	fade_overlay.visible = true
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	callback.call()
	
	var tween_in = create_tween()
	tween_in.tween_property(fade_overlay, "color:a", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween_in.finished
	fade_overlay.visible = false

func _on_roll_dice_pressed():
	btn_roll_dice.disabled = true
	btn_roll_dice.visible = false
	
	# Parada de dados: Instinto (3) + Navegação (5) = 8 D10s. Dificuldade padrão = 6.
	dice_tray.roll_dice(8, 6)

func _on_dice_roll_completed(result: Dictionary):
	var finais = result.get("sucessos_finais", 0)
	var sucessos = result.get("sucessos_brutos", 0)
	var uns = result.get("uns_rolados", 0)
	
	# Avalia os três patamares exigidos pelo design narrativo:
	if finais <= 0:
		# 1. RESULTADO RUIM: Revela o contrabandista que traz complicações (Pólvora Holandesa)
		selected_cargo_id = "ferro_polvora"
		outcome_badge.text = "💀 RESULTADO RUIM (0 Sucessos Finais)"
		outcome_badge.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
		
		outcome_narrative.text = "A fumaça acre do salão arde em teus olhos e o barulho de risadas e copos quebrando te desorienta. Tu tropeças sem querer na mesa dos fundos, onde bebe Baltazar 'Perna de Pau' — notório contrabandista de guerra ligado a piratas e revoltosos.\n\nEle te agarra com mão de ferro: '— Nem penses em recusar, tropeiro... Meus caixotes de pólvora e ferro sobem a serra nas tuas bruacas hoje, ou tu e tua mulinha não saem vivos desta vila!' "
		
		rumor_box.visible = false
		GameManager.boato_cachoeira_descoberto = false
		btn_start_journey.text = "AMARRAR A PÓLVORA & ENCARAR O PERIGO ▶"
		
	elif finais >= 1 and finais <= 2:
		# 2. BOM RESULTADO: Revela a carga mais segura (Sal & Charque da Fazenda Real)
		selected_cargo_id = "sal_charque"
		outcome_badge.text = "⚖️ BOM RESULTADO (%d Sucesso%s)" % [finais, "s" if finais > 1 else ""]
		outcome_badge.add_theme_color_override("font_color", Color(0.45, 0.95, 0.55))
		
		outcome_narrative.text = "Teu tirocínio e tirocínio tropeiro filtram a algazarra da taverna. Tu notas a postura ereta do Feitor Gaspar no canto do balcão, conferindo listas com o selo real da Capitania de São Vicente.\n\nUm funcionário da Coroa procurando mulas de confiança para abastecer o Colégio e os ranchos do planalto. Carga segura, salvo-conduto oficial contra patrulhas e pagamento garantido pelos cofres públicos."
		
		rumor_box.visible = false
		GameManager.boato_cachoeira_descoberto = false
		btn_start_journey.text = "AMARRAR O SAL & INICIAR A SUBIDA SEGURA ▶"
		
	else:
		# 3. SUCESSO ABSOLUTO (3+ Sucessos): Revela a melhor opção (Jesuíta) + BOATO SECRETO!
		selected_cargo_id = "fumo_reliquias"
		outcome_badge.text = "✨ SUCESSO ABSOLUTO (%d Sucessos Finais!)" % finais
		outcome_badge.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25))
		
		outcome_narrative.text = "Teus sentidos afiados dominam a taverna por inteiro! No reservado dos fundos, tu localizas Frei Lourenço da Companhia de Jesus, escoltando caixas com fumo aromático de oferenda e relíquias santas — a comitiva mais rentável de Santos.\n\nCarga leve (15 arrobas), pagamento generoso em patacas de prata e oferendas naturais que acalmam as entidades da serra."
		
		rumor_box.visible = true
		rumor_text.text = "📜 BOATO REVELADO (Mesa ao Lado):\n« Enquanto Frei Lourenço contava suas orações, teus ouvidos apanharam o sussurro de dois marujos bêbados no balcão: '— ...juro pela Virgem! Na subida de Paranapiacaba, antes da Garganta das Águas, há uma reentrância na pedra atrás da Cachoeira do Véu... Um capitão bandeirante escondeu um baú forrado de ferro cheio de patacas ali antes de morrer!' »"
		
		GameManager.boato_cachoeira_descoberto = true
		btn_start_journey.text = "AMARRAR RELÍQUIAS & SUBIR COM O SEGREDO ▶"
	
	_select_cargo(selected_cargo_id)
	
	# Revela o painel com animação de subida suave
	revelation_panel.visible = true
	revelation_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(revelation_panel, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _select_cargo(cargo_id: String):
	selected_cargo_id = cargo_id
	var cargo = GameManager.cargos_catalog[cargo_id]
	
	cargo_title.text = "📦 " + cargo["name"].to_upper() + " — " + cargo["category"]
	
	cargo_stats.text = "💰 Pagamento: %d Réis | ⚖️ Peso: %s | ⏳ Subida: %.1f Dias | ⚔️ Risco da Coroa: %d/5" % [
		cargo["lucro_reis"], cargo["peso"], cargo["dias_viagem"], cargo["risco_patrulha"]
	]
	
	cargo_desc.text = cargo["desc"] + "\n🌿 Efeito Espiritual: " + cargo["reacao_folclore"]
	
	# Estilo visual de seleção nas abas
	tab_sal.modulate = Color(1.2, 1.2, 1.2) if cargo_id == "sal_charque" else Color(0.65, 0.65, 0.65)
	tab_ferro.modulate = Color(1.2, 1.2, 1.2) if cargo_id == "ferro_polvora" else Color(0.65, 0.65, 0.65)
	tab_fumo.modulate = Color(1.2, 1.2, 1.2) if cargo_id == "fumo_reliquias" else Color(0.65, 0.65, 0.65)

func _on_start_journey_pressed():
	# Grava seleções no GameManager e vai para o pátio da estalagem (Página 4)
	GameManager.select_cargo(selected_cargo_id)
	_fade_transition(func():
		_go_to_stage(Stage.PAGE_4_ESTALAGEM)
	)

func _on_partir_noite_pressed():
	GameManager.periodo_partida = "noite"
	_iniciar_subida()

func _on_partir_dia_pressed():
	GameManager.periodo_partida = "dia"
	_iniciar_subida()

func _iniciar_subida():
	GameManager.select_archetype_by_id("tropeiro")
	GameManager.select_cargo(selected_cargo_id)
	_fade_transition(func():
		get_tree().change_scene_to_file("res://Scenes/SubidaSerra.tscn")
	)

func _on_explorar_cidade_pressed():
	modal_feedback.text = "Escolha um local da vila para visitar:"
	city_modal.visible = true

func _on_visit_store_pressed():
	modal_feedback.text = "🏬 Venda do Mestre Bento: Tu compraste fumo aromático de rolo e provisões de farinha com parte do adiantamento! (+1 Fumo de Oferenda adicionado à bruaca)"

func _on_visit_square_pressed():
	modal_feedback.text = "⛪ Praça da Matriz & Pelourinho: Viajantes sussurram sobre névoa densa e assobios folclóricos perto da Cachoeira do Véu... A serra não perdoa descuidos!"

func _on_return_estalagem_pressed():
	city_modal.visible = false
