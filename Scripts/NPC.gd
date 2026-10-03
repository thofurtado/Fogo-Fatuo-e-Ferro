extends Area2D

signal interaction_requested(npc_name, dialogue_lines)

@export var character_name: String = "Tião Caboclo"
@export var dialogues: Array[String] = [
	"Êta nóis! Cuidado com a mata fechada quando a noite cai...",
	"Olhe ali aquela chama azul dançando no meio das pedras! É o Fogo-Fátuo!",
	"Segure firme seu ferro frio, moço! É ele que espanta assombração e protege a gente."
]

@onready var sprite = $Sprite2D
var player_in_range: bool = false
var current_dialogue_idx: int = 0
var idle_time: float = 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta):
	idle_time += delta * 3.0
	# Leve respiração de gibi
	sprite.scale.y = 1.0 + sin(idle_time) * 0.03

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