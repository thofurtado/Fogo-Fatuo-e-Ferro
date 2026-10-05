extends Control

# ==============================================================================
# FLUXO COMPLETO DE CRIAÇÃO DE PERSONAGEM (FOGO-FÁTUO & FERRO - 1645)
# ==============================================================================
# Sequência canônica do Storyboard:
# 1. SPLASH: Capa de abertura mascarando tempo de carregamento (~2.8s) -> Fade to black
# 2. ORIGIN: Mapa-múndi 1645 (Apenas "Brasil" disponível; Europa e África travadas) -> Fade to black
# 3. CLASS: Escolha de Arquétipo ("O Tropeiro" e "O Nativo" disponíveis; "O Desertor" travado com aviso de origem).
#           Avatar exibido em destaque na caixa! Visualização da matriz B.A.N.D.E.I.R.A. -> Fade to black
# 4. REGION: Mapa do Brasil dividido em 6 Macro-Regiões balanceadas (escala de 200² quadros).
#            Apenas regiões 1, 4 e 6 disponíveis; 2, 3 e 5 travadas. -> Fade to black
# 5. SHEET PREVIEW: Exibição da ficha pronta de personagem por alguns segundos. -> Fade to black
# 6. TELA PRETA & PRÓLOGO: Breve silêncio e transição para o Prólogo (PrologoTropeiro.tscn).
#
# DISTRIBUIÇÃO ESPACIAL DAS TELAS (Refinada):
# - Cartões informativos de texto posicionados no RODAPÉ de cada página.
# - Botões de confirmação e de voltar para a tela anterior dispostos logo ACIMA
#   do cartão informativo (fora da caixa de texto).
# - Tipografia ampliada para conforto visual e leitura rápida.
# ==============================================================================

enum Step {
	SPLASH,
	ORIGIN,
	CLASS,
	REGION,
	SHEET_PREVIEW
}

var current_step: Step = Step.SPLASH
var is_transitioning: bool = false

# Variáveis de Seleção
var selected_origin_id: String = "brasil"
var selected_archetype_id: String = "tropeiro"
var selected_region_id: int = 4

# Referências aos Painéis das Etapas
@onready var panel_splash = $PanelSplash
@onready var panel_origin = $PanelOrigin
@onready var panel_class = $PanelClass
@onready var panel_region = $PanelRegion
@onready var panel_sheet = $PanelSheetPreview
@onready var transition_overlay = $TransitionOverlay

# Elementos do Painel Splash (Etapa 1)
@onready var splash_loading_label = $PanelSplash/VBoxBottom/LoadingLabel
@onready var splash_sub_label = $PanelSplash/VBoxBottom/SubLabel
@onready var btn_skip_splash = $PanelSplash/BtnSkipSplash

# Elementos da Seleção de Origem (Etapa 2)
@onready var btn_origin_brasil = $PanelOrigin/ScrollContainer/VBoxContent/CardsContainer/CardBrasil
@onready var btn_origin_europa = $PanelOrigin/ScrollContainer/VBoxContent/CardsContainer/CardEuropa
@onready var btn_origin_africa = $PanelOrigin/ScrollContainer/VBoxContent/CardsContainer/CardAfrica
@onready var btn_back_origin = $PanelOrigin/ActionBar/BtnBackOrigin
@onready var btn_confirm_origin = $PanelOrigin/ActionBar/BtnConfirmOrigin
@onready var origin_info_title = $PanelOrigin/FooterInfoPanel/Margin/VBox/OriginInfoTitle
@onready var origin_info_status = $PanelOrigin/FooterInfoPanel/Margin/VBox/OriginInfoStatus
@onready var origin_info_desc = $PanelOrigin/FooterInfoPanel/Margin/VBox/OriginInfoDesc

# Elementos da Seleção de Arquétipo (Etapa 3)
@onready var btn_class_tropeiro = $PanelClass/ScrollContainer/VBoxContent/TabsContainer/BtnClassTropeiro
@onready var btn_class_nativo = $PanelClass/ScrollContainer/VBoxContent/TabsContainer/BtnClassNativo
@onready var btn_class_desertor = $PanelClass/ScrollContainer/VBoxContent/TabsContainer/BtnClassDesertor

@onready var avatar_rect = $PanelClass/ScrollContainer/VBoxContent/AvatarSection/AvatarFrame/AvatarRect
@onready var avatar_lock_overlay = $PanelClass/ScrollContainer/VBoxContent/AvatarSection/AvatarFrame/LockOverlay
@onready var avatar_lock_label = $PanelClass/ScrollContainer/VBoxContent/AvatarSection/AvatarFrame/LockOverlay/LockText
@onready var class_name_label = $PanelClass/ScrollContainer/VBoxContent/AvatarSection/VBoxHeader/ClassNameLabel
@onready var class_title_label = $PanelClass/ScrollContainer/VBoxContent/AvatarSection/VBoxHeader/ClassTitleLabel
@onready var class_status_badge = $PanelClass/ScrollContainer/VBoxContent/AvatarSection/VBoxHeader/ClassStatusBadge

@onready var bandeira_grid = $PanelClass/ScrollContainer/VBoxContent/BandeiraPanel/Margin/VBox/BandeiraGrid
@onready var btn_back_class = $PanelClass/ActionBar/BtnBackClass
@onready var btn_confirm_class = $PanelClass/ActionBar/BtnConfirmClass
@onready var class_passive_label = $PanelClass/FooterDetailsPanel/Margin/VBox/PassiveLabel
@onready var class_item_label = $PanelClass/FooterDetailsPanel/Margin/VBox/ItemLabel
@onready var class_desc_label = $PanelClass/FooterDetailsPanel/Margin/VBox/DescLabel

# Elementos da Seleção de Região (Etapa 4)
@onready var region_buttons = [
	$PanelRegion/ScrollContainer/VBoxContent/RegionGrid/BtnReg1,
	$PanelRegion/ScrollContainer/VBoxContent/RegionGrid/BtnReg2,
	$PanelRegion/ScrollContainer/VBoxContent/RegionGrid/BtnReg3,
	$PanelRegion/ScrollContainer/VBoxContent/RegionGrid/BtnReg4,
	$PanelRegion/ScrollContainer/VBoxContent/RegionGrid/BtnReg5,
	$PanelRegion/ScrollContainer/VBoxContent/RegionGrid/BtnReg6
]
@onready var btn_back_region = $PanelRegion/ActionBar/BtnBackRegion
@onready var btn_confirm_region = $PanelRegion/ActionBar/BtnConfirmRegion
@onready var region_info_title = $PanelRegion/FooterRegionInfoPanel/Margin/VBox/RegionTitle
@onready var region_info_climate = $PanelRegion/FooterRegionInfoPanel/Margin/VBox/RegionClimate
@onready var region_info_hazards = $PanelRegion/FooterRegionInfoPanel/Margin/VBox/RegionHazards
@onready var region_info_totem = $PanelRegion/FooterRegionInfoPanel/Margin/VBox/RegionTotem
@onready var region_info_desc = $PanelRegion/FooterRegionInfoPanel/Margin/VBox/RegionDesc

# Elementos do Preview da Ficha (Etapa 5)
@onready var btn_back_sheet = $PanelSheetPreview/ActionBar/BtnBackSheet
@onready var btn_confirm_sheet = $PanelSheetPreview/ActionBar/BtnConfirmSheet
@onready var btn_advance_sheet = $PanelSheetPreview/BtnAdvanceSheet
@onready var sheet_timer_label = $PanelSheetPreview/FooterBannerBottom/TimerLabel

var sheet_countdown: float = 3.5

func _ready():
	# Inicializa opacidade da transição no preto e faz fade-in
	transition_overlay.color = Color(0, 0, 0, 1.0)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_hide_all_panels()
	panel_splash.visible = true
	
	# Conexões da Etapa 1 (Splash)
	btn_skip_splash.pressed.connect(_on_skip_splash)
	
	# Conexões da Etapa 2 (Origem)
	btn_origin_brasil.pressed.connect(func(): _select_origin("brasil"))
	btn_origin_europa.pressed.connect(func(): _select_origin("europa"))
	btn_origin_africa.pressed.connect(func(): _select_origin("africa"))
	btn_back_origin.pressed.connect(_on_back_to_menu)
	btn_confirm_origin.pressed.connect(_on_confirm_origin)
	
	# Conexões da Etapa 3 (Classe)
	btn_class_tropeiro.pressed.connect(func(): _select_archetype("tropeiro"))
	btn_class_nativo.pressed.connect(func(): _select_archetype("nativo"))
	btn_class_desertor.pressed.connect(func(): _select_archetype("desertor"))
	btn_back_class.pressed.connect(func(): _transition_to_step(Step.ORIGIN))
	btn_confirm_class.pressed.connect(_on_confirm_class)
	
	# Conexões da Etapa 4 (Região)
	for i in range(region_buttons.size()):
		var reg_id = i + 1
		region_buttons[i].pressed.connect(func(): _select_region(reg_id))
	btn_back_region.pressed.connect(func(): _transition_to_step(Step.CLASS))
	btn_confirm_region.pressed.connect(_on_confirm_region)
	
	# Conexões da Etapa 5 (Ficha Pronta)
	btn_back_sheet.pressed.connect(func(): _transition_to_step(Step.REGION))
	btn_confirm_sheet.pressed.connect(_on_advance_from_sheet)
	btn_advance_sheet.pressed.connect(_on_advance_from_sheet)
	
	# Inicia valores padrão
	_select_origin("brasil")
	_select_archetype("tropeiro")
	_select_region(4) # Região 4: Litoral e Rotas de Serra
	
	# Animação inicial de fade-in da capa
	var tween = create_tween()
	tween.tween_property(transition_overlay, "color:a", 0.0, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_start_splash_sequence()

func _process(delta: float):
	# Atualiza contador no preview da ficha se ativo
	if current_step == Step.SHEET_PREVIEW and not is_transitioning:
		sheet_countdown -= delta
		if sheet_timer_label:
			sheet_timer_label.text = "Iniciando Prólogo em %.1fs... (Toque para avançar agora)" % max(0.0, sheet_countdown)
		if sheet_countdown <= 0.0:
			_on_advance_from_sheet()

func _hide_all_panels():
	panel_splash.visible = false
	panel_origin.visible = false
	panel_class.visible = false
	panel_region.visible = false
	panel_sheet.visible = false

# ==============================================================================
# TRANSIÇÃO SUAVE (FADE TO BLACK TOTAL -> CARREGA PRÓXIMA TELA -> FADE IN)
# ==============================================================================
func _transition_to_step(next_step: Step):
	if is_transitioning:
		return
	is_transitioning = true
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 1. Fade para o preto total
	var tween_out = create_tween()
	tween_out.tween_property(transition_overlay, "color:a", 1.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween_out.finished
	
	# 2. Alterna telas enquanto tudo está 100% preto
	_hide_all_panels()
	current_step = next_step
	
	match next_step:
		Step.ORIGIN:
			panel_origin.visible = true
			_update_origin_ui()
		Step.CLASS:
			panel_class.visible = true
			_update_class_ui()
		Step.REGION:
			panel_region.visible = true
			_update_region_ui()
		Step.SHEET_PREVIEW:
			panel_sheet.visible = true
			sheet_countdown = 3.5
	
	# Pequeno respiro na tela preta para sensação de carregamento imersivo
	await get_tree().create_timer(0.12).timeout
	
	# 3. Fade-in do preto para a nova tela
	var tween_in = create_tween()
	tween_in.tween_property(transition_overlay, "color:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween_in.finished
	
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false

# ==============================================================================
# ETAPA 1: SPLASH (CAPA MASCARANDO CARREGAMENTO)
# ==============================================================================
func _start_splash_sequence():
	# Efeito de pulso suave no texto de carregamento
	var pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(splash_loading_label, "modulate:a", 0.35, 0.8).set_trans(Tween.TRANS_SINE)
	pulse_tween.tween_property(splash_loading_label, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)
	
	# Aguarda ~2.8 segundos antes de avançar para a Origem
	await get_tree().create_timer(2.8).timeout
	if current_step == Step.SPLASH and not is_transitioning:
		_transition_to_step(Step.ORIGIN)

func _on_skip_splash():
	if current_step == Step.SPLASH and not is_transitioning:
		_transition_to_step(Step.ORIGIN)

# ==============================================================================
# ETAPA 2: SELEÇÃO DE ORIGEM (MAPA-MÚNDI 1645)
# ==============================================================================
func _select_origin(origin_id: String):
	selected_origin_id = origin_id
	_update_origin_ui()

func _update_origin_ui():
	var is_br = (selected_origin_id == "brasil")
	var is_eu = (selected_origin_id == "europa")
	var is_af = (selected_origin_id == "africa")
	
	btn_origin_brasil.modulate = Color(1.25, 1.15, 0.9) if is_br else Color(0.9, 0.9, 0.9)
	btn_origin_europa.modulate = Color(0.65, 0.65, 0.65)
	btn_origin_africa.modulate = Color(0.65, 0.65, 0.65)
	
	if is_br:
		origin_info_title.text = "🌎 BRASIL (AMÉRICA PORTUGUESA - 1645)"
		origin_info_desc.text = "Terra vasta de floresta equatorial, mata atlântica virgem, picadas de serra e rios bravios. Pátria de nações originárias guerreiras e dos primeiros tropeiros e sertanistas da Capitania de São Vicente."
		origin_info_status.text = "✦ DISPONÍVEL NESTA VERSÃO ✦"
		origin_info_status.modulate = Color(0.3, 0.9, 0.4)
		btn_confirm_origin.disabled = false
		btn_confirm_origin.text = "ESCOLHER ORIGEM: BRASIL ▶"
		btn_confirm_origin.modulate = Color(1.0, 1.0, 1.0)
	elif is_eu:
		origin_info_title.text = "🏰 EUROPA (REINO DE PORTUGAL & PROVÍNCIAS UNIDAS)"
		origin_info_desc.text = "Metrópoles coloniais distantes, armas de fogo avançadas, corsários holandeses e veteranos de guerra de Flandres. Requer a expansão de personagens além-mar (O Desertor da Coroa)."
		origin_info_status.text = "🔒 BLOQUEADO (Indisponível nesta demo)"
		origin_info_status.modulate = Color(0.9, 0.3, 0.3)
		btn_confirm_origin.disabled = true
		btn_confirm_origin.text = "🔒 ORIGEM INDISPONÍVEL"
		btn_confirm_origin.modulate = Color(0.6, 0.6, 0.6)
	elif is_af:
		origin_info_title.text = "👑 ÁFRICA (COSTA OCIDENTAL / BANTOS & YORUBÁS)"
		origin_info_desc.text = "Tradições ancestrais, mestres forjadores de ferro, curandeiros das ervas e guerreiros quilombolas de resistência. Requer a expansão de campanhas de Palmares."
		origin_info_status.text = "🔒 BLOQUEADO (Indisponível nesta demo)"
		origin_info_status.modulate = Color(0.9, 0.3, 0.3)
		btn_confirm_origin.disabled = true
		btn_confirm_origin.text = "🔒 ORIGEM INDISPONÍVEL"
		btn_confirm_origin.modulate = Color(0.6, 0.6, 0.6)

func _on_confirm_origin():
	if selected_origin_id == "brasil":
		GameManager.selected_origin = "brasil"
		_transition_to_step(Step.CLASS)

func _on_back_to_menu():
	if is_transitioning:
		return
	is_transitioning = true
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween_out = create_tween()
	tween_out.tween_property(transition_overlay, "color:a", 1.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween_out.finished
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

# ==============================================================================
# ETAPA 3: SELEÇÃO DE ARQUÉTIPO / CLASSE
# ==============================================================================
func _select_archetype(arch_id: String):
	selected_archetype_id = arch_id
	_update_class_ui()

func _update_class_ui():
	# Destacar botão selecionado
	btn_class_tropeiro.modulate = Color(1.25, 1.15, 0.8) if selected_archetype_id == "tropeiro" else Color(0.8, 0.8, 0.8)
	btn_class_nativo.modulate = Color(1.25, 1.15, 0.8) if selected_archetype_id == "nativo" else Color(0.8, 0.8, 0.8)
	btn_class_desertor.modulate = Color(1.1, 0.8, 0.8) if selected_archetype_id == "desertor" else Color(0.55, 0.55, 0.55)
	
	# Busca dados do arquétipo no GameManager
	var arch_data: Dictionary = {}
	for arch in GameManager.archetypes_catalog:
		if arch["id"] == selected_archetype_id:
			arch_data = arch
			break
	
	if arch_data.is_empty():
		return
	
	class_name_label.text = arch_data["name"].to_upper()
	class_title_label.text = arch_data["title"]
	class_passive_label.text = "✦ PASSIVA: " + arch_data["passive"]
	class_item_label.text = "🎒 EQUIPAMENTO INICIAL: " + arch_data["initial_item"]
	class_desc_label.text = arch_data["desc"]
	
	if selected_archetype_id == "tropeiro":
		avatar_lock_overlay.visible = false
		class_status_badge.text = "✦ PRONTO PARA JOGAR (CAMPANHA DISPONÍVEL) ✦"
		class_status_badge.modulate = Color(0.3, 0.95, 0.4)
		btn_confirm_class.disabled = false
		btn_confirm_class.text = "CONFIRMAR O TROPEIRO (PRONTO) ▶"
		btn_confirm_class.modulate = Color(1.0, 1.0, 1.0)
		
		# Carrega avatar na caixa
		var tex_path = arch_data.get("avatar_texture", "")
		if tex_path != "" and ResourceLoader.exists(tex_path):
			avatar_rect.texture = load(tex_path)
			avatar_rect.visible = true
			avatar_rect.modulate = Color(1, 1, 1, 1)
		else:
			avatar_rect.visible = false
	elif selected_archetype_id == "nativo":
		# Papa Pin - CHEGANDO EM BREVE
		avatar_lock_overlay.visible = true
		avatar_lock_label.text = "🔒 CHEGANDO EM BREVE\n\nCampanha das Florestas & Rios\n(Liberado no Próximo Ato)"
		class_status_badge.text = "🔒 CHEGANDO EM BREVE (Campanha em Desenvolvimento)"
		class_status_badge.modulate = Color(0.95, 0.65, 0.2)
		btn_confirm_class.disabled = true
		btn_confirm_class.text = "🔒 PERSONAGEM CHEGANDO EM BREVE"
		btn_confirm_class.modulate = Color(0.6, 0.6, 0.6)
		
		var tex_path = arch_data.get("avatar_texture", "")
		if tex_path != "" and ResourceLoader.exists(tex_path):
			avatar_rect.texture = load(tex_path)
			avatar_rect.visible = true
			avatar_rect.modulate = Color(0.6, 0.6, 0.6, 0.7)
		else:
			avatar_rect.visible = false
	else:
		# O Desertor da Coroa - CHEGANDO EM BREVE
		avatar_lock_overlay.visible = true
		avatar_lock_label.text = "🔒 CHEGANDO EM BREVE\n\nCampanha Militar da Coroa\n(Requer Origem Europeia)"
		class_status_badge.text = "🔒 CHEGANDO EM BREVE (Campanha em Desenvolvimento)"
		class_status_badge.modulate = Color(0.95, 0.65, 0.2)
		btn_confirm_class.disabled = true
		btn_confirm_class.text = "🔒 PERSONAGEM CHEGANDO EM BREVE"
		btn_confirm_class.modulate = Color(0.6, 0.6, 0.6)
		avatar_rect.texture = null
		avatar_rect.visible = false
	
	# Atualiza matriz B.A.N.D.E.I.R.A.
	_populate_bandeira_grid(arch_data.get("bandeira", {}))

func _populate_bandeira_grid(bandeira: Dictionary):
	# Limpa filhos anteriores da grade
	for child in bandeira_grid.get_children():
		child.queue_free()
	
	var attr_list = [
		{"letter": "B", "name": "Bravura", "val": bandeira.get("bravura", 0), "icon": "⚔️"},
		{"letter": "A", "name": "Agilidade", "val": bandeira.get("agilidade", 0), "icon": "⚡"},
		{"letter": "N", "name": "Navegação", "val": bandeira.get("navegacao", 0), "icon": "🧭"},
		{"letter": "D", "name": "Destreza", "val": bandeira.get("destreza", 0), "icon": "🎯"},
		{"letter": "E", "name": "Empenho", "val": bandeira.get("empenho", 0), "icon": "🎒"},
		{"letter": "I", "name": "Instinto", "val": bandeira.get("instinto", 0), "icon": "👁️"},
		{"letter": "R", "name": "Raciocínio", "val": bandeira.get("raciocinio", 0), "icon": "🧠"},
		{"letter": "A", "name": "Astúcia", "val": bandeira.get("astucia", 0), "icon": "🎭"}
	]
	
	for item in attr_list:
		var panel = PanelContainer.new()
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.12, 0.1, 0.08, 0.9)
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = Color(0.65, 0.55, 0.35, 0.8)
		sb.corner_radius_top_left = 5
		sb.corner_radius_top_right = 5
		sb.corner_radius_bottom_right = 5
		sb.corner_radius_bottom_left = 5
		panel.add_theme_stylebox_override("panel", sb)
		panel.custom_minimum_size = Vector2(125, 40)
		
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 6)
		
		var lbl_name = Label.new()
		lbl_name.text = "%s %s:" % [item["letter"], item["name"]]
		lbl_name.add_theme_color_override("font_color", Color(0.95, 0.88, 0.72))
		lbl_name.add_theme_font_size_override("font_size", 13)
		
		var dots = ""
		for d in range(5):
			dots += "●" if d < item["val"] else "○"
		
		var lbl_val = Label.new()
		lbl_val.text = "%d [%s]" % [item["val"], dots]
		lbl_val.add_theme_color_override("font_color", Color(1.0, 0.88, 0.4) if item["val"] >= 4 else Color(0.9, 0.9, 0.9))
		lbl_val.add_theme_font_size_override("font_size", 13)
		
		hbox.add_child(lbl_name)
		hbox.add_child(lbl_val)
		panel.add_child(hbox)
		bandeira_grid.add_child(panel)

func _on_confirm_class():
	# Apenas avança se a classe for o Tropeiro (o único pronto nesta versão)
	if selected_archetype_id == "tropeiro":
		GameManager.select_archetype_by_id("tropeiro")
		_transition_to_step(Step.REGION)

# ==============================================================================
# ETAPA 4: SELEÇÃO DE MACRO-REGIÃO DO BRASIL (6 REGIÕES BALANCEADAS)
# ==============================================================================
func _select_region(region_id: int):
	selected_region_id = region_id
	_update_region_ui()

func _update_region_ui():
	# Apenas a Região 4 (Litoral e Rotas de Serra) está pronta nesta demo
	var allowed_regions = [4]
	
	for i in range(region_buttons.size()):
		var reg_id = i + 1
		var btn = region_buttons[i]
		var is_selected = (selected_region_id == reg_id)
		var is_available = allowed_regions.has(reg_id)
		
		if is_available:
			if is_selected:
				btn.modulate = Color(1.3, 1.2, 0.8) # Destaque dourado
			else:
				btn.modulate = Color(1.0, 1.0, 1.0)
		else:
			# Travada / Bloqueada
			btn.modulate = Color(0.5, 0.45, 0.45, 0.7)
	
	var reg_data = GameManager.regions_catalog.get(selected_region_id, {})
	if reg_data.is_empty():
		return
	
	region_info_title.text = "📍 " + reg_data["name"].to_upper()
	region_info_climate.text = "🌦️ Clima & Terreno: " + reg_data["clima"]
	region_info_hazards.text = "⚠️ Perigos Primários: " + reg_data["perigos"]
	region_info_totem.text = "🏛️ Totem de Renascimento: " + reg_data["totem"]
	region_info_desc.text = reg_data["desc"]
	
	var is_reg_available = allowed_regions.has(selected_region_id)
	if is_reg_available:
		btn_confirm_region.disabled = false
		btn_confirm_region.text = "CONFIRMAR ROTA DA SERRA (PRONTA) ▶"
		btn_confirm_region.modulate = Color(1.0, 1.0, 1.0)
	else:
		btn_confirm_region.disabled = true
		btn_confirm_region.text = "🔒 REGIÃO BLOQUEADA (CHEGANDO EM BREVE)"
		btn_confirm_region.modulate = Color(0.6, 0.6, 0.6)

func _on_confirm_region():
	if selected_region_id == 4:
		GameManager.selected_region_id = 4
		_transition_to_step(Step.SHEET_PREVIEW)

# ==============================================================================
# ETAPA 5: EXIBIÇÃO DA FICHA PRONTA E TRANSIÇÃO PARA O PRÓLOGO
# ==============================================================================
func _on_advance_from_sheet():
	if current_step == Step.SHEET_PREVIEW and not is_transitioning:
		_finish_creation_and_enter_prologue()

func _finish_creation_and_enter_prologue():
	if is_transitioning:
		return
	is_transitioning = true
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Salva seleções finais no GameManager
	GameManager.selected_origin = "brasil"
	GameManager.select_archetype_by_id("tropeiro")
	GameManager.selected_region_id = 4
	
	# Transição rápida de fade para preto (0.3s)
	var tween_out = create_tween()
	tween_out.tween_property(transition_overlay, "color:a", 1.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween_out.finished
	
	# Transição direta para o Prólogo (PrologoTropeiro.tscn)
	var err = get_tree().change_scene_to_file("res://Scenes/PrologoTropeiro.tscn")
	if err != OK:
		push_error("Falha ao abrir PrologoTropeiro.tscn: " + str(err))