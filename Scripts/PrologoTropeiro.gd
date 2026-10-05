extends Control

@onready var cargo_title = $UILayer/CargoPanel/MarginContainer/VBoxContainer/CargoTitle
@onready var cargo_stats = $UILayer/CargoPanel/MarginContainer/VBoxContainer/CargoStats
@onready var cargo_desc = $UILayer/CargoPanel/MarginContainer/VBoxContainer/CargoDesc
@onready var btn_confirm = $UILayer/CargoPanel/MarginContainer/VBoxContainer/BtnConfirm

@onready var btn_sal = $UILayer/ChoiceButtons/BtnSal
@onready var btn_ferro = $UILayer/ChoiceButtons/BtnFerro
@onready var btn_fumo = $UILayer/ChoiceButtons/BtnFumo

@onready var black_screen = $UILayer/TelaPreta
@onready var black_screen_text = $UILayer/TelaPreta/CenterContainer/VBoxContainer/TransitionText
@onready var black_screen_subtext = $UILayer/TelaPreta/CenterContainer/VBoxContainer/TransitionSubtext
@onready var btn_enter_world = $UILayer/TelaPreta/CenterContainer/VBoxContainer/BtnEnterWorld

var selected_cargo_id: String = "sal_charque"

func _ready():
	black_screen.visible = false
	
	btn_sal.pressed.connect(func(): _select_cargo("sal_charque"))
	btn_ferro.pressed.connect(func(): _select_cargo("ferro_polvora"))
	btn_fumo.pressed.connect(func(): _select_cargo("fumo_reliquias"))
	
	btn_confirm.pressed.connect(_on_confirm_pressed)
	btn_enter_world.pressed.connect(_on_enter_world_pressed)
	
	_select_cargo("sal_charque")

func _select_cargo(cargo_id: String):
	selected_cargo_id = cargo_id
	var cargo = GameManager.cargos_catalog[cargo_id]
	
	cargo_title.text = "📦 " + cargo["name"].to_upper() + " — " + cargo["category"]
	
	cargo_stats.text = "💰 Pagamento: %d Réis | ⚖️ Peso: %s | ⏳ Subida: %.1f Dias\n⚔️ Risco da Coroa: %d/5 | 🌿 Reação Folclórica: %s" % [
		cargo["lucro_reis"], cargo["peso"], cargo["dias_viagem"], cargo["risco_patrulha"], cargo["reacao_folclore"]
	]
	
	cargo_desc.text = cargo["desc"]
	
	# Estilo visual de seleção nos botões
	btn_sal.modulate = Color(1.2, 1.2, 1.2) if cargo_id == "sal_charque" else Color(0.7, 0.7, 0.7)
	btn_ferro.modulate = Color(1.2, 1.2, 1.2) if cargo_id == "ferro_polvora" else Color(0.7, 0.7, 0.7)
	btn_fumo.modulate = Color(1.2, 1.2, 1.2) if cargo_id == "fumo_reliquias" else Color(0.7, 0.7, 0.7)

func _on_confirm_pressed():
	# 1. Configura o Tropeiro no GameManager
	GameManager.select_archetype_by_id("tropeiro")
	GameManager.select_cargo(selected_cargo_id)
	
	var cargo = GameManager.current_cargo
	
	# 2. CORTE SECO PARA TELA PRETA (Sem dissoluções, direto ao preto)
	black_screen.visible = true
	
	black_screen_text.text = "ANO DE 1645 — CAPITANIA DE SÃO VICENTE\n\nA marcha serra acima se inicia com a carga de:\n【 %s 】" % cargo["name"].to_upper()
	
	black_screen_subtext.text = "Tempo estimado de travessia: %.1f Dias de subida íngreme.\nVelocidade da tropa: %d%% da velocidade normal.\n\nO som dos cascos ecoa contra o paredão de pedra da Serra do Mar..." % [
		cargo["dias_viagem"], int(cargo["velocidade_micro"] * 100)
	]

func _on_enter_world_pressed():
	# Troca direto para a cena jogável da Subida da Serra de Paranapiacaba
	get_tree().change_scene_to_file("res://Scenes/SubidaSerra.tscn")
