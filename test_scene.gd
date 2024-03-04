extends Control

@onready var dialogue_control = $DialogueControl

@onready var dialogue_options = {
	$DialogueOptions/DialogueOptionsButton1: "res://test_dialogues/test_dialogue_1.txt",
	$DialogueOptions/DialogueOptionsButton2: "res://test_dialogues/test_dialogue_2.txt",
	$DialogueOptions/DialogueOptionsButton3: "res://test_dialogues/test_dialogue_3.txt",
}

@onready var dialogue_speed_option_button = $DialogSpeed/DialogueSpeedOptionButton
@onready var dialogue_mode_option_button = $DialogMode/DialogueModeOptionButton

@onready var dialogue_mode_options = {
	"character" : dialogue_control.write_mode.CHARACTER,
	"word" : dialogue_control.write_mode.WORD,
	"line" : dialogue_control.write_mode.LINE,
}

@onready var dialogue_speed_options = {
	"slow" : dialogue_control.write_speed.SLOW,
	"normal" : dialogue_control.write_speed.NORMAL,
	"fast" : dialogue_control.write_speed.FAST,
}



func _ready():
	for button in dialogue_options:
		button.pressed.connect(dialogue_control.load_dialogue_from_TXT.bind(dialogue_options[button]))
		button.pressed.connect(button.release_focus)
		
	dialogue_speed_option_button.item_selected.connect(_on_dialogue_speed_selected)
	dialogue_mode_option_button.item_selected.connect(_on_dialogue_mode_selected)
	
	
	dialogue_control.set_dialogue_write_mode(dialogue_mode_options["character"])
	dialogue_control.set_dialogue_write_speed(dialogue_speed_options["normal"])


func _process(delta):
	if get_node_or_null("InfoLayer"):
		update_infolayer()


func update_infolayer():
	$InfoLayer/CurrentDialogueOption.text = str("Current dialogue option: ", dialogue_control.dialogue_file_path)
	$InfoLayer/CurrentLineInDialogue.text = str("Current line in dialogue: ", dialogue_control.line_index)


func _on_dialogue_mode_selected(index : int):
	var dialogue_mode_selected = dialogue_mode_options[dialogue_mode_option_button.get_item_text(index)]
	dialogue_control.set_dialogue_write_mode(dialogue_mode_selected)
	dialogue_speed_option_button.release_focus()


func _on_dialogue_speed_selected(index : int):
	var dialogue_speed_selected = dialogue_speed_options[dialogue_speed_option_button.get_item_text(index)]
	dialogue_control.set_dialogue_write_speed(dialogue_speed_selected)
	dialogue_speed_option_button.release_focus()

