class_name DialogueControl
extends Control
## Simple control for displaying dialogue box and text
##
## Loads a dialogue as PackedStringArrays from .txt file
## Displays one dialogue line at a time in panel
## Options for writing speeds [write_speed] and modes [write_mode]


# UI elements
@onready var dialogue_panel = $DialoguePanel
@onready var text_display = $DialoguePanel/DialogueText

# file paths
var dialogue_test_file_path = "res://test_dialogue.txt"
var dialogue_file_path = dialogue_test_file_path

# dialogue object
var dialogue : PackedStringArray

# dialogue variables
var in_dialogue = false
var line_index = 0;
var current_line : String
var writing_line = false

# writing modes and speed
enum write_mode {
	CHARACTER,
	WORD,
	LINE,
}

const write_speed = {
	SLOW = 0.1,
	NORMAL = 0.05,
	FAST = 0.02
}

var dialogue_write_mode : write_mode = write_mode.CHARACTER
var dialogue_write_speed : float = write_speed.NORMAL

var test_dialogue = PackedStringArray(["Hi there, is this the first time you've used the dialogue system?", "Don't worry, it will be smooth sailing from here on out"])

func _ready():
	reset_dialogue()
	dialogue_file_path = dialogue_test_file_path
	load_dialogue_from_TXT(dialogue_file_path)


func _process(delta):
	if Input.is_action_just_pressed("space"):
		show_next_dialogue_line()


func load_dialogue_from_PSA(new_dialogue : PackedStringArray):
	dialogue = PackedStringArray(new_dialogue)


func load_dialogue_from_TXT(file_path):
	dialogue_file_path = file_path
	
	if FileAccess.file_exists(dialogue_file_path):
		var file = FileAccess.open(dialogue_file_path, FileAccess.READ)
		
		dialogue = PackedStringArray()
		
		while not file.eof_reached():
			var string_array = file.get_csv_line()
			var string = "".join(string_array)
			if string.is_empty():
				return
			dialogue.append(string)


func set_dialogue_write_speed(speed : float):
	dialogue_write_speed = speed


func set_dialogue_write_mode(mode : write_mode):
	dialogue_write_mode = mode


func reset_dialogue():
	hide_dialogue_panel()
	clear_text_display()
	line_index = 0
	in_dialogue = false


func show_dialogue_panel():
	dialogue_panel.show()
	text_display.show()


func hide_dialogue_panel():
	dialogue_panel.hide()
	text_display.hide()


func set_text_display(text : String):
	text_display.text = text


func clear_text_display():
	text_display.clear()


func show_next_dialogue_line():
	
	# start of dialogue
	if not in_dialogue:
		show_dialogue_panel()
		write_line(dialogue[0], dialogue_write_mode)
		in_dialogue = true
	
	# feed next line
	elif line_index < dialogue.size() - 1 or writing_line:
		clear_text_display()
		
		# complete current line if writing
		if writing_line:
			writing_line = false
			clear_text_display()
			set_text_display(get_line_in_dialogue(line_index))
		
		# write next line if line complete
		else:
			line_index +=1
			write_line(get_line_in_dialogue(line_index), dialogue_write_mode)
	
	# end of dialogue
	else:
		writing_line = false
		reset_dialogue()


func get_line_in_dialogue(index : int) -> String:
	return dialogue[index]


func write_line(line : String, mode : write_mode):
	match mode:
		write_mode.LINE:
			text_display.append_text(line)
			
		write_mode.WORD:
			write_line_per_word(line)
			
		write_mode.CHARACTER:
			write_line_per_character(line)


func write_line_per_character(line : String):
	writing_line = true
	
	var parsing_bbcode = false
	var bbcode_string = String()
	
	# iterate current line
	for c in range(line.length()):
		
		# break if player interrupts
		if not writing_line:
			break
		
		# get character to parse
		var current_character = line[c]
		
		# check for bbcode open
		if current_character == "[" and not parsing_bbcode:
			parsing_bbcode = true
			bbcode_string += current_character
			continue
		
		# continue parsing bbcode
		if parsing_bbcode:
			# add character to bbcode string
			bbcode_string += current_character
			
			# check for end of bbcode append text
			if current_character == "]":
				set_text_display(line.substr(0, c+1))
				bbcode_string = String()
				parsing_bbcode = false
				continue
		
		if not parsing_bbcode:
			text_display.append_text(current_character)
			await get_tree().create_timer(dialogue_write_speed).timeout
		
	writing_line = false


func write_line_per_word(line : String):
	writing_line = true
	
	var current_word = String()
	var parsing_bbcode = false
	var bbcode_open_counter = 0
	var bbcode_close_counter = 0
	
	# iterate line character by character
	for c in range(line.length()):
		
		# break if player interrupts
		if not writing_line:
			break
		
		# get character to parse
		var current_character = line[c]
		
		# add character to current word
		current_word += current_character
		
		# check for bbcode
		if current_character == "[":
			parsing_bbcode = true
			bbcode_open_counter += 1
		
		# close bbcode
		if current_character == "]":
			bbcode_close_counter += 1
			if bbcode_close_counter == bbcode_open_counter and bbcode_open_counter > 1:
				parsing_bbcode = false
		
		# rip debug
		# print("i: " + str(c) + ", C:" + current_character + ", WORD: " + current_word)
		
		# check for spaces or end of line, while not parsing bbcode
		if (current_character == " " and not parsing_bbcode) or c == (line.length() - 1):
			# use append_text method instead of setting text to prevent resetting animation
			text_display.append_text(current_word)
			#set_text_display(line.substr(0, c+1))
			current_word = String()
			await get_tree().create_timer(dialogue_write_speed).timeout
	
	writing_line = false
