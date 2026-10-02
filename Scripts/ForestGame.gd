extends Control

@onready var bg_dia = $BackgroundDia
@onready var bg_noite = $BackgroundNoite
@onready var player = $Player
@onready var amuleto = $Amuleto
@onready var dialogue_box = $UILayer/DialogueBox
@onready var dialogue_label = $UILayer/DialogueBox/MarginContainer/HBoxContainer/VBoxContainer/DialogueText
@onready var day_night_label = $UILayer/TopHUD/DayNightNotice

var is_night: bool = false
var player_near_amulet: bool = false

func _ready():
	bg_noite.modulate.a = 0.0
	dialogue_box.visible = false
	amuleto.body_entered.connect(_on_amulet_entered)
	amuleto.body_exited.connect(_on_amulet_exited)

func _process(delta):
	# Transição suave entre dia e noite
	var target_alpha = 1.0 if is_night else 0.0
	bg_noite.modulate.a = lerp(bg_noite.modulate.a, target_alpha, delta * 4.0)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_N:
			is_night = !is_night
			if is_night:
				day_night_label.text = "NOITE (Névoa, Pegadas do Curupira & Cogumelos Brilhantes)"
				day_night_label.modulate = Color(0.4, 0.8, 1.0)
			else:
				day_night_label.text = "DIA (Sol na Copa & Trilha Aberta)"
				day_night_label.modulate = Color(1.0, 0.9, 0.5)

		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			if player_near_amulet:
				dialogue_box.visible = !dialogue_box.visible

func _on_amulet_entered(body):
	if body.name == "Player":
		player_near_amulet = true
		dialogue_box.visible = true
		dialogue_label.text = "O Curupira te deixou um amuleto. Escolha um caminho para investigar..."

func _on_amulet_exited(body):
	if body.name == "Player":
		player_near_amulet = false