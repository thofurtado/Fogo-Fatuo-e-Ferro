extends Area2D

signal interaction_requested(npc_name, dialogue_lines)

@export var character_name: String = "Tião Caboclo"
@export var dialogues: Array[String] = [
	"Êta nóis! Cuidado com a mata fechada quando a noite cai...",
	"Dizem que o Fogo-Fátuo dança no brejo pra desencaminhar viajante.",
	"Segure firme seu ferro frio, moço! É ele que espanta assombração."
]

var player_in_range: bool = false
var current_dialogue_idx: int = 0

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event):
	if player_in_range and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_SPACE or event.is_action("ui_accept"):
			var text = dialogues[current_dialogue_idx]
			current_dialogue_idx = (current_dialogue_idx + 1) % dialogues.size()
			interaction_requested.emit(character_name, text)

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false

func _draw():
	# Sombra
	draw_circle(Vector2(0, 15), 14, Color(0.1, 0.1, 0.1, 0.35))
	
	# Corpo com colete/camisa vermelha estilo gibi
	draw_circle(Vector2(0, 2), 13, Color(0.85, 0.25, 0.2))
	draw_arc(Vector2(0, 2), 13, 0, TAU, 32, Color(0.05, 0.05, 0.05), 3.0)
	
	# Cabeça
	draw_circle(Vector2(0, -12), 11, Color(0.96, 0.76, 0.55))
	draw_arc(Vector2(0, -12), 11, 0, TAU, 32, Color(0.05, 0.05, 0.05), 3.0)
	
	# Bigode e sobrancelhas marcantes de cartum clássico
	draw_circle(Vector2(-4, -13), 2.2, Color(0.05, 0.05, 0.05))
	draw_circle(Vector2(4, -13), 2.2, Color(0.05, 0.05, 0.05))
	draw_line(Vector2(-6, -9), Vector2(6, -9), Color(0.1, 0.1, 0.1), 3.0)
	
	# Gorro / Lenço
	var hat_points = PackedVector2Array([
		Vector2(-12, -18),
		Vector2(12, -18),
		Vector2(0, -28)
	])
	draw_colored_polygon(hat_points, Color(0.2, 0.65, 0.3))
	draw_polyline(PackedVector2Array([
		Vector2(-12, -18), Vector2(12, -18), Vector2(0, -28), Vector2(-12, -18)
	]), Color(0.05, 0.05, 0.05), 2.5)