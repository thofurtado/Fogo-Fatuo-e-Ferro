extends Node

# Singleton GameManager - Gerencia o estado global do RPG Fogo-Fátuo & Ferro

signal character_selected(archetype_id)
signal stat_changed(stat_name, new_val)
signal item_collected(item_name)

var current_archetype: Dictionary = {
	"id": "nativo",
	"name": "O Jovem Nativo",
	"title": "A Resistência da Terra",
	"forca": 2,
	"destreza": 4,
	"labia": 1,
	"misticismo": 4,
	"vida_max": 12,
	"vida_atual": 12,
	"mana_max": 10,
	"mana_atual": 10,
	"initial_item": "Amuleto de Semente Sagrada",
	"passive": "Passo Leve: Imune a lentidão na mata fechada"
}

var archetypes_catalog: Array[Dictionary] = [
	{
		"id": "nativo",
		"name": "O Jovem Nativo",
		"title": "Resistência e Conhecimento da Terra",
		"forca": 2, "destreza": 4, "labia": 1, "misticismo": 4,
		"vida_max": 12, "mana_max": 10,
		"initial_item": "Amuleto de Semente Sagrada",
		"passive": "Passo Leve: Comunicação natural com as entidades.",
		"desc": "Conhece cada folha e raiz da floresta. Luta para proteger os seus e a mata sagrada da pólvora e do ferro."
	},
	{
		"id": "fugitivo",
		"name": "A Escravizada Fugitiva",
		"title": "Astúcia e Sobrevivência Guerrilheira",
		"forca": 4, "destreza": 3, "labia": 2, "misticismo": 2,
		"vida_max": 14, "mana_max": 6,
		"initial_item": "Corrente de Ferro Partida",
		"passive": "Resiliência: Resistência física extrema e instinto de sobrevivência.",
		"desc": "Quebrou os grilhões do cativeiro. Busca a liberdade nos quilombos e usa a astúcia para despistar milícias."
	},
	{
		"id": "desertor",
		"name": "O Desertor da Coroa",
		"title": "O Mestre do Ferro e da Pólvora",
		"forca": 3, "destreza": 3, "labia": 2, "misticismo": 0,
		"vida_max": 15, "mana_max": 4,
		"initial_item": "Pistola de Pederneira Gasta",
		"passive": "Ferreiro de Campanha: Opera armas de fogo e fortificações.",
		"desc": "Virou as costas para a violência da Coroa. Carrega o peso do ferro com que feriu a terra, buscando redenção."
	},
	{
		"id": "clerigo",
		"name": "O Clérigo Renegado",
		"title": "Fé em Crise e Erudição Mística",
		"forca": 1, "destreza": 2, "labia": 4, "misticismo": 4,
		"vida_max": 10, "mana_max": 14,
		"initial_item": "Breviário com Ervas Medicinais",
		"passive": "Sincretismo: Capacidade de ler códigos arcanos e realizar rituais.",
		"desc": "Enviado para a catequese, descobriu que o sagrado na floresta desafia os dogmas da Igreja."
	},
	{
		"id": "tropeiro",
		"name": "O Tropeiro Itinerante",
		"title": "Senhor das Rotas e Comerciante",
		"forca": 2, "destreza": 2, "labia": 5, "misticismo": 2,
		"vida_max": 12, "mana_max": 8,
		"initial_item": "Bruaca de Couro & Fumo de Rolo",
		"passive": "Mula de Carga: Inventário dobrado e rotas comerciais seguras.",
		"desc": "Percorre as estradas reais e picadas de contrabando. Conhece o valor do ferro e a oferenda certa para os espíritos."
	}
]

var inventory: Array[String] = []
var quest_curupira_amulet: bool = false
var has_curupira_blessing: bool = false

func select_archetype(index: int):
	if index >= 0 and index < archetypes_catalog.size():
		var chosen = archetypes_catalog[index].duplicate()
		chosen["vida_atual"] = chosen["vida_max"]
		chosen["mana_atual"] = chosen["mana_max"]
		current_archetype = chosen
		inventory.clear()
		inventory.append(chosen["initial_item"])
		character_selected.emit(chosen["id"])

func add_item(item_name: String):
	inventory.append(item_name)
	item_collected.emit(item_name)