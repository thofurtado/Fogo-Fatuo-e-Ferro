extends Node2D

@onready var shader_rect = $PostProcessLayer/ColorRect
@onready var dialogue_panel = $UILayer/DialogueBubble
@onready var dialogue_text = $UILayer/DialogueBubble/MarginContainer/VBoxContainer/DialogueLabel
@onready var speaker_label = $UILayer/DialogueBubble/MarginContainer/VBoxContainer/SpeakerLabel
@onready var hud_status = $UILayer/HUD/MarginContainer/VBoxContainer/ShaderStatusLabel
@onready var npc = $NPC
@onready var player = $Player

var shader_active: bool = true

func _ready():
	npc.interaction_requested.connect(_on_npc_interaction)
	dialogue_panel.visible = false
	_update_hud()

func _unhandled_input(event):
	# Alternar shader com a tecla G
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_G:
			shader_active = !shader_active
			var mat = shader_rect.material as ShaderMaterial
			if mat:
				mat.set_shader_parameter("effect_enabled", shader_active)
			_update_hud()

func _update_hud():
	if shader_active:
		hud_status.text = "ESTILO GIBI: [ATIVADO] (Pressione 'G' para desativar)"
		hud_status.modulate = Color(0.2, 0.9, 0.2)
	else:
		hud_status.text = "ESTILO GIBI: [DESATIVADO] (Pressione 'G' para ativar)"
		hud_status.modulate = Color(0.9, 0.3, 0.2)

func _on_npc_interaction(speaker_name: String, text: String):
	speaker_label.text = speaker_name.to_upper() + ":"
	dialogue_text.text = text.to_upper()
	dialogue_panel.visible = true
	# Posiciona o balão próximo ao NPC
	dialogue_panel.global_position = npc.global_position + Vector2(-150, -110)