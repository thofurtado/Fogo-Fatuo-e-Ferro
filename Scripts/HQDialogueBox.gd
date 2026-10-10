extends Control
class_name HQDialogueBox

# ==============================================================================
# HQ DIALOGUE & NARRATOR SYSTEM — FOGO FÁTUO & FERRO (MOBILE 9:16)
# ==============================================================================
# - Narrador: Caixa retangular vertical na lateral direita (5-6 linhas).
# - Diálogo de Personagem: Rodapé da página (2-3 linhas por vez).
# - Toque em qualquer lugar da tela avança a leitura.
# - Letras grandes (16-18px), fonte legível, visual xilogravura/HQ.
# ==============================================================================

signal line_started(item: Dictionary)
signal sequence_completed

@onready var touch_overlay: Button = $TouchOverlay

@onready var narrator_container: PanelContainer = $NarratorContainer
@onready var narrator_title: Label = $NarratorContainer/Margin/VBox/NarratorTitle
@onready var narrator_text: RichTextLabel = $NarratorContainer/Margin/VBox/NarratorText
@onready var narrator_prompt: Label = $NarratorContainer/Margin/VBox/NarratorPrompt

@onready var dialogue_container: PanelContainer = $DialogueContainer
@onready var speaker_name: Label = $DialogueContainer/Margin/VBox/SpeakerName
@onready var dialogue_text: RichTextLabel = $DialogueContainer/Margin/VBox/DialogueText
@onready var dialogue_prompt: Label = $DialogueContainer/Margin/VBox/DialoguePrompt

var _queue: Array = []
var _current_item: Dictionary = {}
var _is_active: bool = false
var _is_typing: bool = false
var _active_rtl: RichTextLabel = null
var _typewriter_tween: Tween = null

func _ready():
	touch_overlay.pressed.connect(_on_touch_pressed)
	narrator_container.visible = false
	dialogue_container.visible = false
	touch_overlay.visible = false

func is_dialogue_active() -> bool:
	return _is_active

## Inicia uma sequência de falas e narrações.
## Cada item pode ser:
## { "type": "narrator", "text": "...", "title": "📜 O NARRADOR" (opcional) }
## { "type": "dialogue", "speaker": "Mestre Bento", "text": "..." }
func play_sequence(sequence: Array):
	_queue = sequence.duplicate(true)
	_is_active = true
	touch_overlay.visible = true
	touch_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_advance_queue()

## Limpa e fecha as caixas imediatamente
func stop():
	_queue.clear()
	_is_active = false
	_is_typing = false
	if _typewriter_tween and _typewriter_tween.is_valid():
		_typewriter_tween.kill()
	narrator_container.visible = false
	dialogue_container.visible = false
	touch_overlay.visible = false

func _advance_queue():
	if _queue.is_empty():
		_is_active = false
		touch_overlay.visible = false
		narrator_container.visible = false
		dialogue_container.visible = false
		emit_signal("sequence_completed")
		return

	_current_item = _queue.pop_front()
	var item_type = _current_item.get("type", "dialogue")
	var full_text = _current_item.get("text", "")

	if item_type == "narrator":
		dialogue_container.visible = false
		narrator_container.visible = true
		narrator_title.text = _current_item.get("title", "📜 O NARRADOR")
		narrator_text.text = full_text
		narrator_prompt.modulate.a = 0.0
		_start_typewriter(narrator_text, narrator_prompt)
	else:
		narrator_container.visible = false
		dialogue_container.visible = true
		speaker_name.text = _current_item.get("speaker", "Voz:")
		dialogue_text.text = full_text
		dialogue_prompt.modulate.a = 0.0
		_start_typewriter(dialogue_text, dialogue_prompt)

	emit_signal("line_started", _current_item)

func _start_typewriter(rtl: RichTextLabel, prompt: Label):
	_active_rtl = rtl
	_is_typing = true
	rtl.visible_ratio = 0.0
	
	if _typewriter_tween and _typewriter_tween.is_valid():
		_typewriter_tween.kill()
		
	var duration = max(0.4, rtl.text.length() * 0.018)
	_typewriter_tween = create_tween()
	_typewriter_tween.tween_property(rtl, "visible_ratio", 1.0, duration).set_trans(Tween.TRANS_LINEAR)
	_typewriter_tween.finished.connect(func():
		_is_typing = false
		_show_prompt(prompt)
	)

func _show_prompt(prompt: Label):
	var tween = create_tween().set_loops()
	tween.tween_property(prompt, "modulate:a", 1.0, 0.4)
	tween.tween_property(prompt, "modulate:a", 0.3, 0.4)

func _finish_typewriter_instantly():
	if _typewriter_tween and _typewriter_tween.is_valid():
		_typewriter_tween.kill()
	if _active_rtl:
		_active_rtl.visible_ratio = 1.0
	_is_typing = false
	if narrator_container.visible:
		_show_prompt(narrator_prompt)
	if dialogue_container.visible:
		_show_prompt(dialogue_prompt)

func _on_touch_pressed():
	if not _is_active:
		return
	if _is_typing:
		# Primeiro toque pula o efeito de máquina de escrever
		_finish_typewriter_instantly()
	else:
		# Segundo toque avança para a próxima linha
		_advance_queue()

func _unhandled_input(event: InputEvent):
	if not _is_active:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and not event.echo):
		_on_touch_pressed()
		get_viewport().set_input_as_handled()
