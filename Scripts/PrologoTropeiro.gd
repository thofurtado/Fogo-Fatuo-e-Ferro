extends Control

# ==============================================================================
# PRÓLOGO INTERATIVO DO TROPEIRO (1645) — HISTÓRIA EM QUADRINHOS & ROLAGEM
# ==============================================================================
# Reformulado para padrão Mobile (9:16) com leitura limpa e dinâmica:
# - Narrador: Caixa vertical à direita (5-6 linhas).
# - Diálogo: Rodapé da página (2-3 linhas por vez).
# - Toque em qualquer lugar da tela avança a leitura.
# - Sem painéis gigantes cobrindo a arte!
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
@onready var hq_dialogue: HQDialogueBox = $UILayer/HQDialogue

@onready var page1_container: PanelContainer = $UILayer/Page1Container
@onready var btn_page1_next: Button = $UILayer/Page1Container/Margin/VBox/BtnPage1Next

@onready var page2_container: PanelContainer = $UILayer/Page2Container
@onready var btn_page2_next: Button = $UILayer/Page2Container/Margin/VBox/BtnPage2Next

@onready var page3_container: Control = $UILayer/Page3DiceContainer
@onready var dice_tray = $UILayer/Page3DiceContainer/DiceTray
@onready var btn_roll_dice: Button = $UILayer/Page3DiceContainer/RollButtonContainer/BtnRollDice

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
	GameManager.select_archetype_by_id("tropeiro")
	
	fade_overlay.visible = false
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.color = Color(0, 0, 0, 0)
	
	# Conexões de botões
	btn_page1_next.pressed.connect(_on_page1_next)
	btn_page2_next.pressed.connect(_on_page2_next)
	btn_roll_dice.pressed.connect(_on_roll_dice_pressed)
	
	dice_tray.roll_completed.connect(_on_dice_roll_completed)
	
	btn_partir_noite.pressed.connect(_on_partir_noite_pressed)
	btn_partir_dia.pressed.connect(_on_partir_dia_pressed)
	btn_explorar_cidade.pressed.connect(_on_explorar_cidade_pressed)
	
	btn_visit_store.pressed.connect(_on_visit_store_pressed)
	btn_visit_square.pressed.connect(_on_visit_square_pressed)
	btn_return_estalagem.pressed.connect(_on_return_estalagem_pressed)
	
	_go_to_stage(Stage.PAGE_1_CAIS)

func _go_to_stage(new_stage: Stage):
	current_stage = new_stage
	hq_dialogue.stop()
	
	match current_stage:
		Stage.PAGE_1_CAIS:
			bg_rect.texture = TEX_PAGE_1
			page1_container.visible = false
			page2_container.visible = false
			page3_container.visible = false
			page4_container.visible = false
			city_modal.visible = false
			
			hq_dialogue.play_sequence([
				{ "type": "narrator", "title": "📜 CAPÍTULO I — O CAIS DE SANTOS", "text": "O salitre do mar da Capitania de São Vicente mistura-se ao suor dos marinheiros e ao cheiro de peixe seco." },
				{ "type": "narrator", "title": "📜 CAPÍTULO I — O CAIS DE SANTOS", "text": "Diante de ti, além dos telhados coloniais, ergue-se a colossal muralha verde da Serra de Paranapiacaba." },
				{ "type": "dialogue", "speaker": "Tropeiro Tião:", "text": "« — Aguenta firme, Bonita... Para subir o planalto até São Paulo de Piratininga, precisamos de uma carga paga. »" },
				{ "type": "dialogue", "speaker": "Tropeiro Tião:", "text": "« — E o único lugar para achar serviço a essa hora é na taverna do cais... »" }
			])
			await hq_dialogue.sequence_completed
			page1_container.visible = true
			
		Stage.PAGE_2_TAVERNA:
			bg_rect.texture = TEX_PAGE_2
			page1_container.visible = false
			page2_container.visible = false
			page3_container.visible = false
			page4_container.visible = false
			city_modal.visible = false
			
			hq_dialogue.play_sequence([
				{ "type": "narrator", "title": "🍺 A TAVERNA DO PESCADOR TORTO", "text": "A porta de madeira range e a fumaça de cachimbo te engole. O salão ferve de marujos e mercadores." },
				{ "type": "dialogue", "speaker": "Mestre Bento (Taverneiro):", "text": "« — Entrai, tropeiro... tirai a poeira dos pés e cuidai das vossas algibeiras. »" },
				{ "type": "dialogue", "speaker": "Mestre Bento (Taverneiro):", "text": "« — Há três homens neste salão com prata viva e pressa de mandar carga morro acima antes da chuva. »" },
				{ "type": "dialogue", "speaker": "Mestre Bento (Taverneiro):", "text": "« — Uns trazem o ferro da guerra; outros trazem o sal da Câmara... e outros guardam segredos santos. Olhai bem antes de dar vossa palavra! »" }
			])
			await hq_dialogue.sequence_completed
			page2_container.visible = true
			
		Stage.PAGE_3_DICE_ROLL:
			bg_rect.texture = TEX_PAGE_3
			page1_container.visible = false
			page2_container.visible = false
			page3_container.visible = true
			page4_container.visible = false
			city_modal.visible = false
			btn_roll_dice.visible = true
			btn_roll_dice.disabled = false
			dice_tray.setup_dice(8)
			
			hq_dialogue.play_sequence([
				{ "type": "narrator", "title": "🎲 TESTE DE PERCEPÇÃO", "text": "O salão está esfumaçado e cheio de sussurros.\n\nRola os teus dados na bandeja de couro para ver o que teus olhos de tropeiro conseguem discernir entre as sombras." }
			])
			
		Stage.PAGE_4_ESTALAGEM:
			bg_rect.texture = TEX_PAGE_4
			page1_container.visible = false
			page2_container.visible = false
			page3_container.visible = false
			page4_container.visible = false
			city_modal.visible = false
			
			var cargo = GameManager.cargos_catalog[selected_cargo_id]
			cargo_badge_estalagem.text = "📦 Carga Escolhida: %s (%s) — Pagamento: %d Réis" % [cargo["name"], cargo["category"], cargo["lucro_reis"]]
			
			var client_sequence = []
			if selected_cargo_id == "fumo_reliquias":
				client_sequence = [
					{ "type": "dialogue", "speaker": "Frei Lourenço:", "text": "« — A paz de Cristo, meu filho. Disseram-me que tua mula Bonita tem casco duro para vencer a serra. »" },
					{ "type": "dialogue", "speaker": "Frei Lourenço:", "text": "« — Levo fumo de oferenda e santos de marfim para o Colégio de Piratininga. Pago trinta patacas de prata se as relíquias chegarem secas. »" },
					{ "type": "narrator", "title": "📜 BOATO REVELADO", "text": "Enquanto o padre contava suas orações, teus ouvidos apanharam o sussurro de marujos na mesa ao lado: juram haver um baú de ferro escondido atrás da Cachoeira do Véu!" }
				]
			elif selected_cargo_id == "sal_charque":
				client_sequence = [
					{ "type": "dialogue", "speaker": "Feitor Gaspar:", "text": "« — Salve, tropeiro. A Câmara de São Vicente precisa de cinco bruacas de sal e charque no planalto com urgência. »" },
					{ "type": "dialogue", "speaker": "Feitor Gaspar:", "text": "« — Carga oficial da Coroa. Trago salvo-conduto contra patrulhas e pagamento garantido pelos cofres públicos na chegada. »" }
				]
			else: # ferro_polvora
				client_sequence = [
					{ "type": "dialogue", "speaker": "Baltazar Perna de Pau:", "text": "« — Nem penses em recusar, tropeiro... Meus caixotes de pólvora e ferro sobem a serra nas tuas bruacas hoje! »" },
					{ "type": "dialogue", "speaker": "Baltazar Perna de Pau:", "text": "« — Se a patrulha da Coroa farejar a carga, o couro é teu. Leva tudo intacto até o alto e terás 40 patacas... ou não passas do pé da serra! »" }
				]
				
			hq_dialogue.play_sequence(client_sequence)
			await hq_dialogue.sequence_completed
			page4_container.visible = true

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
	hq_dialogue.stop()
	dice_tray.roll_dice(8, 6)

func _on_dice_roll_completed(result: Dictionary):
	var finais = result.get("sucessos_finais", 0)
	var outcome_sequence = []
	
	if finais <= 0:
		selected_cargo_id = "ferro_polvora"
		GameManager.boato_cachoeira_descoberto = false
		outcome_sequence = [
			{ "type": "narrator", "title": "💀 RESULTADO RUIM (0 Sucessos)", "text": "A fumaça acre arde em teus olhos e o barulho de copos te desorienta. Tu tropeças sem querer na mesa dos fundos..." },
			{ "type": "narrator", "title": "💀 RESULTADO RUIM (0 Sucessos)", "text": "Ali bebe Baltazar 'Perna de Pau', notório contrabandista ligado a revoltosos... Ele te agarra com mão de ferro para uma missão perigosa!" }
		]
	elif finais >= 1 and finais <= 2:
		selected_cargo_id = "sal_charque"
		GameManager.boato_cachoeira_descoberto = false
		outcome_sequence = [
			{ "type": "narrator", "title": "⚖️ BOM RESULTADO (%d Sucesso%s)" % [finais, "s" if finais > 1 else ""], "text": "Teus ouvidos tropeiros filtram a algazarra da taverna. Tu notas a postura ereta do Feitor Gaspar no balcão..." },
			{ "type": "narrator", "title": "⚖️ BOM RESULTADO (%d Sucesso%s)" % [finais, "s" if finais > 1 else ""], "text": "Um homem da Coroa com o selo real, procurando mulas de confiança para abastecer o planalto com sal e charque com salvo-conduto." }
		]
	else:
		selected_cargo_id = "fumo_reliquias"
		GameManager.boato_cachoeira_descoberto = true
		outcome_sequence = [
			{ "type": "narrator", "title": "✨ SUCESSO ABSOLUTO (%d Sucessos!)" % finais, "text": "Teus sentidos afiados dominam a taverna por inteiro! No reservado dos fundos, uma figura de preto se destaca..." },
			{ "type": "narrator", "title": "✨ SUCESSO ABSOLUTO (%d Sucessos!)" % finais, "text": "É Frei Lourenço da Companhia de Jesus, escoltando fumo aromático e relicários santos — a comitiva mais rentável de Santos!" }
		]
		
	hq_dialogue.play_sequence(outcome_sequence)
	await hq_dialogue.sequence_completed
	
	# Transição automática para a conversa na mesa / estalagem
	_fade_transition(func():
		_go_to_stage(Stage.PAGE_4_ESTALAGEM)
	)

func _on_partir_noite_pressed():
	GameManager.partida_noite = true
	_iniciar_subida_serra()

func _on_partir_dia_pressed():
	GameManager.partida_noite = false
	_iniciar_subida_serra()

func _on_explorar_cidade_pressed():
	city_modal.visible = true
	modal_feedback.text = "Escolha um local para visitar antes de subir a serra:"
	modal_feedback.add_theme_color_override("font_color", Color(0.4, 0.95, 0.6))

func _on_visit_store_pressed():
	var cargo = GameManager.cargos_catalog[selected_cargo_id]
	cargo["refeicoes_extras"] = 3
	modal_feedback.text = "✔️ Compraste fumo de mascar, rapadura e cordas extras na venda de secos e molhados (+3 Rações)."
	modal_feedback.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
	btn_visit_store.disabled = true

func _on_visit_square_pressed():
	modal_feedback.text = "✔️ No Largo da Matriz, um pescador idoso te avisou: 'Na subida da serra, se o Boitatá aparecer, não corra nem olhe para trás!'"
	modal_feedback.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
	btn_visit_square.disabled = true

func _on_return_estalagem_pressed():
	city_modal.visible = false

func _iniciar_subida_serra():
	_fade_transition(func():
		get_tree().change_scene_to_file("res://Scenes/SubidaSerra.tscn")
	)
