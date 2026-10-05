extends Node

# Singleton GameManager - Gerencia o estado global do RPG Fogo-Fátuo & Ferro

signal character_selected(archetype_id)
signal stat_changed(stat_name, new_val)
signal item_collected(item_name)
signal origin_selected(origin_id)
signal region_selected(region_id)

var selected_origin: String = "brasil"
var selected_archetype_id: String = "tropeiro"
var selected_region_id: int = 4

var current_archetype: Dictionary = {}

var archetypes_catalog: Array[Dictionary] = [
	{
		"id": "tropeiro",
		"name": "O Tropeiro Paulista",
		"title": "Senhor das Rotas e Mercador da Serra",
		"origin": "brasil",
		"available": true,
		"avatar_texture": "res://Assets/Sprites/tropeiro_mula_estilo_gibi.jpg",
		"bandeira": {
			"bravura": 3, "agilidade": 2, "navegacao": 5, "destreza": 3,
			"empenho": 4, "instinto": 3, "raciocinio": 3, "astucia": 5
		},
		"vida_max": 24, "mana_max": 10,
		"initial_item": "Bruaca de Couro & Facão de Três Listras",
		"passive": "Mula de Carga: Inventário dobrado e rotas comerciais seguras.",
		"desc": "Conduz tropas de muares pelo barro e pedreiras da Serra do Mar. Mestre da barganha, conhece os atalhos e as oferendas certas para a mata."
	},
	{
		"id": "nativo",
		"name": "Papa Pin (Batedor Nativo)",
		"title": "A Resistência e Simbiose com a Terra",
		"origin": "brasil",
		"available": false,
		"avatar_texture": "res://Assets/Sprites/curumim_caminhando.png",
		"bandeira": {
			"bravura": 3, "agilidade": 5, "navegacao": 5, "destreza": 5,
			"empenho": 3, "instinto": 4, "raciocinio": 4, "astucia": 2
		},
		"vida_max": 20, "mana_max": 14,
		"initial_item": "Arco Recurvo & Amuleto de Semente Sagrada",
		"passive": "Passo Silencioso: Imune a emboscadas na mata e agilidade sobre-humana.",
		"desc": "[CHEGANDO EM BREVE] Lê o voo das aves e os murmúrios das águas. Defende as aldeias e a floresta sagrada contra a ganância da pólvora e do ferro."
	},
	{
		"id": "desertor",
		"name": "O Desertor da Coroa",
		"title": "O Mestre do Ferro e da Pólvora",
		"origin": "europa",
		"available": false,
		"avatar_texture": "",
		"bandeira": {
			"bravura": 4, "agilidade": 2, "navegacao": 2, "destreza": 4,
			"empenho": 4, "instinto": 3, "raciocinio": 3, "astucia": 2
		},
		"vida_max": 25, "mana_max": 6,
		"initial_item": "Bacamarte Militar & Pederneira",
		"passive": "Fogo de Campanha: Opera armas de pólvora e fortificações militares.",
		"desc": "[CHEGANDO EM BREVE] Virou as costas para a violência da Coroa. Carrega o peso das armas com que feriu a terra, buscando redenção no sertão."
	}
]

var regions_catalog: Dictionary = {
	1: {
		"id": 1,
		"name": "1. Nordeste Açucareiro",
		"available": false,
		"clima": "Tropical Úmido (Canaviais e Costa)",
		"perigos": "Guerra holandesa (WIC), milícias e capitães-do-mato.",
		"totem": "Capela Litorânea de Taipa",
		"desc": "[CHEGANDO EM BREVE] Zona de guerra aberta e alta densidade militar. Engenhos em chamas, patrulhas de arcabuz e corsários no mar."
	},
	2: {
		"id": 2,
		"name": "2. Sertão do São Francisco",
		"available": false,
		"clima": "Semiárido / Caatinga Cinzenta",
		"perigos": "Insolação, sede severa e cascavéis.",
		"totem": "Lajedo Sagrado dos Índios Cariris",
		"desc": "[BLOQUEADA NESTA DEMO] Terra de vaqueiros primitivos, currais sem cercas e desfiladeiros de pedra abrasadora."
	},
	3: {
		"id": 3,
		"name": "3. Planalto de Piratininga",
		"available": false,
		"clima": "Subtropical de Altitude / Campos Altos",
		"perigos": "Bandeiras de apresamento e mamelucos armados.",
		"totem": "Pouso Tropeiro da Serra",
		"desc": "[BLOQUEADA NESTA DEMO] O berço vicentino das expedições armadas sertão adentro."
	},
	4: {
		"id": 4,
		"name": "4. Litoral e Rotas de Serra",
		"available": true,
		"clima": "Mata Atlântica de Encosta (Chuva e Barro)",
		"perigos": "Precipícios escorregadios, neblina espessa e contrabando.",
		"totem": "Rancho Tropeiro de Cumeeira",
		"desc": "✦ DISPONÍVEL (PRONTA) ✦ A espinha dorsal do tropeirismo. Picadas lamacentas entre o Porto de Santos e os campos do planalto. Ideal para o Tropeiro!"
	},
	5: {
		"id": 5,
		"name": "5. Pantanal e Rios Centrais",
		"available": false,
		"clima": "Inundável / Pântano e Capões",
		"perigos": "Piranhas, febres da várzea e criaturas das águas.",
		"totem": "Canoa Monóxila do Capão Seco",
		"desc": "[BLOQUEADA NESTA DEMO] Expedições de monções fluviais e isolamento profundo nas águas do continente."
	},
	6: {
		"id": 6,
		"name": "6. Sul e Bacia do Prata",
		"available": false,
		"clima": "Pampas e Coxilhas (Vento Minuano)",
		"perigos": "Patrulhas ibéricas disputadas e tempestades pampeiras.",
		"totem": "Pórtico da Missão Jesuítica de Pedra",
		"desc": "[CHEGANDO EM BREVE] Grandes planícies abertas, reduções dos Sete Povos das Missões e tropas de gado selvagem."
	}
}

var inventory: Array[String] = []
var quest_curupira_amulet: bool = false
var has_curupira_blessing: bool = false
var boato_cachoeira_descoberto: bool = false

var current_cargo: Dictionary = {}

var cargos_catalog: Dictionary = {
	"sal_charque": {
		"id": "sal_charque",
		"name": "Sacas de Sal & Charque",
		"category": "Carga Comum (Comércio da Coroa)",
		"lucro_reis": 200,
		"peso": "Pesado (40 arrobas)",
		"velocidade_micro": 0.8,
		"dias_viagem": 2.0,
		"risco_patrulha": 1,
		"reacao_folclore": "Neutra (Entidades ignoram; atrai feras carnívoras)",
		"item_inventario": "Fardo de Charque de Santos",
		"desc": "Alimento vital para as vilas do planalto. Pagamento limpo e seguro pela Câmara. Mulas pesadas e passo cadenciado."
	},
	"ferro_polvora": {
		"id": "ferro_polvora",
		"name": "Caixotes de Ferro & Pólvora Holandesa",
		"category": "Contrabando da Guerra (1645)",
		"lucro_reis": 600,
		"peso": "Muito Pesado (65 arrobas)",
		"velocidade_micro": 0.65,
		"dias_viagem": 3.5,
		"risco_patrulha": 5,
		"reacao_folclore": "Hostil (O 'Cheiro de Ferro' e pólvora enfurece os guardiões da mata)",
		"item_inventario": "Barril de Pólvora Holandesa Clandestina",
		"desc": "Armas para os revoltosos da serra. Paga uma fortuna, mas atrai capitães-do-mato com cães e a fúria do Curupira."
	},
	"fumo_reliquias": {
		"id": "fumo_reliquias",
		"name": "Fumo de Rolo & Relíquias Jesuítas",
		"category": "Carga Mística & Botânica",
		"lucro_reis": 250,
		"peso": "Leve (15 arrobas)",
		"velocidade_micro": 1.0,
		"dias_viagem": 1.5,
		"risco_patrulha": 2,
		"reacao_folclore": "Abençoada (Fumo serve como oferenda automática nas encruzilhadas)",
		"item_inventario": "Rolo de Fumo Sagrado da Mata",
		"desc": "Fumo de corda aromático e unguentos sagrados. Marcha ligeira e atalhos abertos pelos espíritos da serra."
	}
}

func _ready():
	select_archetype_by_id("tropeiro")

func select_archetype_by_id(arch_id: String):
	for arch in archetypes_catalog:
		if arch["id"] == arch_id:
			var chosen = arch.duplicate(true)
			chosen["vida_atual"] = chosen["vida_max"]
			chosen["mana_atual"] = chosen["mana_max"]
			current_archetype = chosen
			selected_archetype_id = arch_id
			inventory.clear()
			inventory.append(chosen["initial_item"])
			character_selected.emit(arch_id)
			return

func select_archetype(index: int):
	if index >= 0 and index < archetypes_catalog.size():
		select_archetype_by_id(archetypes_catalog[index]["id"])

func select_cargo(cargo_id: String):
	if cargos_catalog.has(cargo_id):
		current_cargo = cargos_catalog[cargo_id].duplicate()
		add_item(current_cargo["item_inventario"])

func add_item(item_name: String):
	inventory.append(item_name)
	item_collected.emit(item_name)

func get_bandeira_summary(arch: Dictionary) -> String:
	if not arch.has("bandeira"):
		return ""
	var b = arch["bandeira"]
	return "B: %d | A: %d | N: %d | D: %d | E: %d | I: %d | R: %d | A: %d" % [
		b.get("bravura", 0), b.get("agilidade", 0), b.get("navegacao", 0), b.get("destreza", 0),
		b.get("empenho", 0), b.get("instinto", 0), b.get("raciocinio", 0), b.get("astucia", 0)
	]

func get_bandeira_detailed(arch: Dictionary) -> String:
	if not arch.has("bandeira"):
		return ""
	var b = arch["bandeira"]
	return "⚔️ Bravura: %d   ⚡ Agilidade: %d   🧭 Navegação: %d   🎯 Destreza: %d\n🎒 Empenho: %d   👁️ Instinto: %d   🧠 Raciocínio: %d   🎭 Astúcia: %d" % [
		b.get("bravura", 0), b.get("agilidade", 0), b.get("navegacao", 0), b.get("destreza", 0),
		b.get("empenho", 0), b.get("instinto", 0), b.get("raciocinio", 0), b.get("astucia", 0)
	]
