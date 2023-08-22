# Details of RWM system control panel can be found in NRC document ML023020204
extends CSGBox3D
@onready var node_3d = $"/root/Node3d"

@onready var rwm_button_material = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/RWM_COMP_PROGRAM/RWM_COMP/RWM".get_material()
@onready var comp_button_material = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/RWM_COMP_PROGRAM/RWM_COMP/COMP".get_material()
@onready var program_button_material = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/RWM_COMP_PROGRAM/PROGRAM".get_material()
@onready var withdraw_block_material = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/INSERT_WITHDRAW_BLOCK/WITHDRAW BLOCK".get_material()
@onready var insert_block_material = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/INSERT_WITHDRAW_BLOCK/INSERT BLOCK".get_material()
@onready var select_error_material = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/SELECT_ERROR/SELECT_ERROR".get_material()
@onready var out_of_seq_material = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/OUT_OF_SEQ_SYS_INIT/OUT OF SEQ".get_material()
@onready var system_init_material = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/OUT_OF_SEQ_SYS_INIT/SYSTEM INITIALIZE".get_material()
@onready var manual_bypass_material = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/MANUAL_AUTO_BYPASS/MANUAL".get_material()
@onready var auto_bypass_material = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/MANUAL_AUTO_BYPASS/AUTO".get_material()
@onready var below_lpap_material = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/BELOW_LPAP/BELOW_LPAP".get_material()
@onready var below_lpsp_material = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/BELOW_LPSP/BELOW_LPSP".get_material()
@onready var group_text_object = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Parts/Group/Display/Text"
@onready var withdraw_error_text_object = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Parts/Withdraw Error/Display/Text"
@onready var insert_error_1_text_object = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Parts/Insert Error 1/Display/Text"
@onready var insert_error_2_text_object = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Parts/Insert Error 2/Display/Text"


var rwm_initalized = false
var rwm_inop = true
var current_group = 1
var select_error = false
var current_sequence = "a"

var insert_errors = {}
var withdraw_errors = {}
var withdraw_blocks = ["rwm_inop"]
var insert_blocks = ["rwm_inop"]

# bypasses
var rwm_malfunction = false
var rwm_manual_bypass = false
var rwm_above_lpsp = false
var rwm_above_lpap = false
var alarm_displays_blank = false

# this function is for formatting strings (primarily rod numbers) to be displayed on the RWM panel displays
func format_string(string, remove_dashes = false):
	var final_string = ""
	var first_number = true
	for letter in string:
		if letter == "-" and remove_dashes:
			letter = " "
		if first_number == true:
			final_string = letter
		else:
			final_string = "%s %s" % [final_string, letter]
		first_number = false
	return final_string

# Called when the node enters the scene tree for the first time.
func _ready():
	if rwm_initalized:
		group_text_object.text = format_string(node_3d.make_string_two_digit(str(current_group)))
	else:
		# make displays blank
		group_text_object.text = "   "
		withdraw_error_text_object.text = "         "
		insert_error_1_text_object.text = "         "
		insert_error_2_text_object.text = "         "
		rwm_inop = true
		node_3d.set_object_emission("Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/RWM_COMP_PROGRAM/RWM_COMP/RWM", true)
	while true:
		manual_bypass_material.emission_enabled = rwm_manual_bypass
		# TODO: automatic bypass
		alarm_displays_blank = rwm_manual_bypass
		if alarm_displays_blank:
			withdraw_error_text_object.text = "         "
			insert_error_1_text_object.text = "         "
			insert_error_2_text_object.text = "         "
			group_text_object.text = ""
			out_of_seq_material.emission_enabled = false
			below_lpap_material.emission_enabled = false
			below_lpsp_material.emission_enabled = false
			select_error_material.emission_enabled = false
			node_3d.add_new_block("RWM","r_withdraw_block")
			node_3d.add_new_block("RWM","r_insert_block")
			withdraw_blocks = []
			insert_blocks = []
			insert_block_material.emission_enabled = false
			withdraw_block_material.emission_enabled = false
			
			
		if not rwm_inop and not alarm_displays_blank:
			calculate_data()
			
			# TODO: RWM LPAP/LPSP steam flow bypasses
			below_lpap_material.emission_enabled = true
			below_lpsp_material.emission_enabled = true
			
			out_of_seq_material.emission_enabled = (len(insert_errors) > 2 or withdraw_errors != {}) and not alarm_displays_blank
			withdraw_error_text_object.text = "         "
			for rod in withdraw_errors:
				withdraw_error_text_object.text = format_string(rod, true)
				break
			insert_error_1_text_object.text = "         "
			insert_error_2_text_object.text = "         "
			var runs = 0
			for rod in insert_errors:
				if runs == 0:
					insert_error_2_text_object.text = format_string(rod, true)
				if runs == 1:
					insert_error_1_text_object.text = format_string(rod, true)
					break
				runs += 1
			group_text_object.text = format_string(node_3d.make_string_two_digit(str(current_group)))
			select_error = true
			var group_info = groups["sequence_a"][current_group]
			for rod_number in group_rods["sequence_a"][group_info["rod_group"]]:
				if "|" in rod_number:
					rod_number = rod_number.split("|")[0]
				if node_3d.selected_cr == rod_number:
					select_error = false
					break
			
			select_error_material.emission_enabled = select_error
			
			pass
		elif not alarm_displays_blank:
			if not "rwm_inop" in withdraw_blocks:
				withdraw_blocks.append("rwm_inop")
			if not "rwm_inop" in insert_blocks:
				insert_blocks.append("rwm_inop")
		
		if withdraw_blocks != []:
			withdraw_block_material.emission_enabled = true
			node_3d.add_new_block("RWM","withdraw_block")
		else:
			withdraw_block_material.emission_enabled = false
			node_3d.add_new_block("RWM","r_withdraw_block")
		if insert_blocks != []:
			insert_block_material.emission_enabled = true
			node_3d.add_new_block("RWM","insert_block")
		else:
			insert_block_material.emission_enabled = false
			node_3d.add_new_block("RWM","r_insert_block")
			
		await get_tree().create_timer(1).timeout
		



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func button_pressed(parent, pressed):
	if parent.name == "RWM_COMP_PROGRAM":
		# TODO: simulate RWM malfunctions
		if pressed:
			rwm_button_material.emission_enabled = true
			comp_button_material.emission_enabled = true
			program_button_material.emission_enabled = true
		else:
			rwm_button_material.emission_enabled = rwm_inop
			comp_button_material.emission_enabled = false
			program_button_material.emission_enabled = false
			
	elif parent.name == "SYSTEM_DIAGNOSTIC":
		# TODO: simulate RWM diagnostics
		pass
	elif parent.name == "OUT_OF_SEQ_SYS_INIT":
		system_init_material.emission_enabled = pressed
		if rwm_initalized == false and pressed and not rwm_malfunction:
			# initialise RWM
			withdraw_blocks.erase("rwm_inop")
			withdraw_block_material.emission_enabled = false
			insert_blocks.erase("rwm_inop")
			insert_block_material.emission_enabled = false
			node_3d.add_new_block("RWM","r_withdraw_block")
			rwm_initalized = true
			rwm_inop = false
			
		
func set_rwm_inop(state):
	if state == true:
		rwm_malfunction = true
		rwm_inop = true
		rwm_initalized = false
		current_group = 0
		withdraw_block_material.emission_enabled = true
		node_3d.add_new_block("RWM","withdraw_block")
		withdraw_blocks.append("rwm_inop")
		insert_block_material.emission_enabled = true
		insert_blocks.append("rwm_inop")
		node_3d.add_new_block("RWM","insert_block")
		group_text_object.text = "   "
		withdraw_error_text_object.text = "         "
		insert_error_1_text_object.text = "         "
		insert_error_2_text_object.text = "         "
		node_3d.set_object_emission("Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/RWM_COMP_PROGRAM/RWM_COMP/RWM", true)
		node_3d.set_object_emission("Control Room Panels/Main Panel Center/Meters/RWM Box/Indicators/RWM_COMP_PROGRAM/RWM_COMP/COMP", true)
		select_error_material.emission_enabled = false
		out_of_seq_material.emission_enabled = false
		

func calculate_data():
	# calculate the group
	var latched_group = 1
	for group_number in groups["sequence_a"]:
		# check that all groups 1 through latched_group-1 have <3 insert errors
		var insert_error_count = 0
		for group_number_2 in groups["sequence_a"]:
			if group_number_2 >= latched_group: break
			var group_info = groups["sequence_a"][group_number_2]
			var withdraw_limit = group_info["max_position"]
			var alternate_withdraw_limit = withdraw_limit - 2
			for rod_number in group_rods["sequence_a"][group_info["rod_group"]]:
				if "|" in rod_number:
					rod_number = rod_number.split("|")[0]
				if int(node_3d.control_rods[rod_number]["cr_insertion"]) < withdraw_limit and int(node_3d.control_rods[rod_number]["cr_insertion"]) < alternate_withdraw_limit:
					insert_error_count += 1
		
		var one_rod_past_insert_limit = false
		var group_info = groups["sequence_a"][group_number]
		var insert_limit = group_info["min_position"]
		for rod_number in group_rods["sequence_a"][group_info["rod_group"]]:
			if "|" in rod_number:
				rod_number = rod_number.split("|")[0]
			if int(node_3d.control_rods[rod_number]["cr_insertion"]) > insert_limit:
				one_rod_past_insert_limit = true
				break
		
		if insert_error_count > 3 or !one_rod_past_insert_limit:
			if latched_group != 1:
				latched_group -= 1
			break
		elif latched_group < 72:
			latched_group += 1
	current_group = latched_group
	
	# calculate errors
	insert_errors = {}
	withdraw_errors = {}
	for group_number in groups["sequence_a"]:
		var group_info = groups["sequence_a"][group_number]
		var withdraw_limit = group_info["max_position"]
		var alternate_withdraw_limit = withdraw_limit - 2
		var insert_limit = group_info["min_position"]
		var alternate_insert_limit = insert_limit - 2 if insert_limit != 0 else 2
		for rod_number in group_rods["sequence_a"][group_info["rod_group"]]:
			if "|" in rod_number:
				rod_number = rod_number.split("|")[0]
				
			var rod_position = int(node_3d.control_rods[rod_number]["cr_insertion"])
			
			var insert_error = false
			var withdraw_error = false
			if group_number == current_group:
				insert_error = rod_position < insert_limit and rod_position < alternate_insert_limit
				withdraw_error = rod_position > withdraw_limit
			elif group_number < current_group:
				insert_error = rod_position < withdraw_limit and rod_position < alternate_withdraw_limit
				withdraw_error = rod_position > withdraw_limit
			elif group_number > current_group:
				insert_error = false
				withdraw_error = rod_position > insert_limit
			
			if rod_number in withdraw_errors and not withdraw_error:
				withdraw_errors.erase(rod_number)
				
			if insert_error and rod_number not in insert_errors:
				insert_errors[rod_number] = {
					# these extra information are unused for now, but i'm leaving them here just in case
					"group_number": group_number,
					"rod_group": group_info["rod_group"]
				}
				
			if withdraw_error and rod_number not in withdraw_errors:
				withdraw_errors[rod_number] = {
					"group_number": group_number,
					"rod_group": group_info["rod_group"]
				}
				
	if withdraw_errors != {} and not "Withdraw Error" in withdraw_blocks:
		withdraw_blocks.append("Withdraw Error")
	elif "Withdraw Error" in withdraw_blocks and withdraw_errors == {}:
		withdraw_blocks.erase("Withdraw Error")
					
	if len(insert_errors) > 2 and not "Insert Error" in insert_blocks:
		insert_blocks.append("Insert Error")
	elif "Insert Error" in insert_blocks and len(insert_errors) < 3:
		insert_blocks.erase("Insert Error")
				
	if (len(insert_errors) >= 3 and node_3d.selected_cr not in insert_errors) and ("Insert error with selection error" not in withdraw_blocks):
		withdraw_blocks.append("Insert error with selection error")
	elif "Insert error with selection error" in withdraw_blocks and not (len(insert_errors) >= 3 and node_3d.selected_cr not in insert_errors):
		withdraw_blocks.erase("Insert error with selection error")
				
# rod group data begins here
# TODO: add sequence B (found in NRC document ML20136H955)
var groups = {
	"sequence_a": {
		1: {
			"rod_group":1,
			"min_position":0,
			"max_position":48,
		},
		2: {
			"rod_group":2,
			"min_position":0,
			"max_position":48,
		},
		3: {
			"rod_group":3,
			"min_position":0,
			"max_position":48,
		},
		4: {
			"rod_group":4,
			"min_position":0,
			"max_position":48,
		},
		5: {
			"rod_group":5,
			"min_position":0,
			"max_position":48,
		},
		6: {
			"rod_group":6,
			"min_position":0,
			"max_position":48,
		},
		7: {
			"rod_group":7,
			"min_position":0,
			"max_position":48,
		},
		8: {
			"rod_group":8,
			"min_position":0,
			"max_position":48,
		},
		9: {
			"rod_group":9,
			"min_position":0,
			"max_position":48,
		},
		10: {
			"rod_group":10,
			"min_position":0,
			"max_position":48,
		},
		11: {
			"rod_group":11,
			"min_position":0,
			"max_position":48,
		},
		12: {
			"rod_group":12,
			"min_position":0,
			"max_position":4,
		},
		13: {
			"rod_group":12,
			"min_position":4,
			"max_position":8,
		},
		14: {
			"rod_group":13,
			"min_position":0,
			"max_position":4,
		},
		15: {
			"rod_group":12,
			"min_position":8,
			"max_position":12,
		},
		16: {
			"rod_group":13,
			"min_position":4,
			"max_position":8,
		},
		17: {
			"rod_group":14,
			"min_position":0,
			"max_position":4,
		},
		18: {
			"rod_group":15,
			"min_position":0,
			"max_position":4,
		},
		19: {
			"rod_group":12,
			"min_position":12,
			"max_position":16,
		},
		20: {
			"rod_group":13,
			"min_position":8,
			"max_position":12,
		},
		21: {
			"rod_group":12,
			"min_position":16,
			"max_position":20,
		},
		22: {
			"rod_group":13,
			"min_position":12,
			"max_position":16,
		},
		23: {
			"rod_group":14,
			"min_position":4,
			"max_position":8,
		},
		24: {
			"rod_group":15,
			"min_position":4,
			"max_position":8,
		},
		25: {
			"rod_group":12,
			"min_position":20,
			"max_position":24,
		},
		26: {
			"rod_group":13,
			"min_position":16,
			"max_position":20,
		},
		27: {
			"rod_group":14,
			"min_position":8,
			"max_position":12,
		},
		28: {
			"rod_group":12,
			"min_position":24,
			"max_position":30,
		},
		29: {
			"rod_group":13,
			"min_position":20,
			"max_position":24,
		},
		30: {
			"rod_group":14,
			"min_position":12,
			"max_position":16,
		},
		31: {
			"rod_group":12,
			"min_position":30,
			"max_position":36,
		},
		32: {
			"rod_group":13,
			"min_position":24,
			"max_position":30,
		},
		33: {
			"rod_group":14,
			"min_position":12,
			"max_position":16,
		},
		34: {
			"rod_group":15,
			"min_position":8,
			"max_position":14,
		},
		35: {
			"rod_group":12,
			"min_position":36,
			"max_position":42,
		},
		36: {
			"rod_group":13,
			"min_position":30,
			"max_position":36,
		},
		37: {
			"rod_group":16,
			"min_position":0,
			"max_position":4,
		},
		38: {
			"rod_group":14,
			"min_position":20,
			"max_position":24,
		},
		39: {
			"rod_group":15,
			"min_position":14,
			"max_position":18,
		},
		40: {
			"rod_group":12,
			"min_position":42,
			"max_position":48,
		},
		41: {
			"rod_group":13,
			"min_position":36,
			"max_position":42,
		},
		42: {
			"rod_group":16,
			"min_position":4,
			"max_position":8,
		},
		43: {
			"rod_group":17,
			"min_position":0,
			"max_position":4,
		},
		44: {
			"rod_group":18,
			"min_position":0,
			"max_position":4,
		},
		45: {
			"rod_group":14,
			"min_position":24,
			"max_position":28,
		},
		46: {
			"rod_group":15,
			"min_position":18,
			"max_position":22,
		},
		47: {
			"rod_group":13,
			"min_position":42,
			"max_position":48,
		},
		48: {
			"rod_group":17,
			"min_position":4,
			"max_position":8,
		},
		49: {
			"rod_group":14,
			"min_position":28,
			"max_position":32,
		},
		50: {
			"rod_group":15,
			"min_position":22,
			"max_position":26,
		},
		51: {
			"rod_group":19,
			"min_position":0,
			"max_position":4,
		},
		52: {
			"rod_group":14,
			"min_position":32,
			"max_position":36,
		},
		53: {
			"rod_group":15,
			"min_position":26,
			"max_position":30,
		},
		54: {
			"rod_group":16,
			"min_position":8,
			"max_position":12,
		},
		55: {
			"rod_group":17,
			"min_position":8,
			"max_position":12,
		},
		56: {
			"rod_group":18,
			"min_position":4,
			"max_position":8,
		},
		57: {
			"rod_group":20,
			"min_position":0,
			"max_position":4,
		},
		58: {
			"rod_group":16,
			"min_position":12,
			"max_position":16,
		},
		59: {
			"rod_group":19,
			"min_position":4,
			"max_position":8,
		},
		60: {
			"rod_group":20,
			"min_position":4,
			"max_position":8,
		},
		61: {
			"rod_group":18,
			"min_position":8,
			"max_position":12,
		},
		62: {
			"rod_group":17,
			"min_position":12,
			"max_position":16,
		},
		63: {
			"rod_group":19,
			"min_position":8,
			"max_position":12,
		},
		64: {
			"rod_group":21,
			"min_position":8,
			"max_position":12,
		},
		65: {
			"rod_group":16,
			"min_position":16,
			"max_position":20,
		},
		66: {
			"rod_group":22,
			"min_position":36,
			"max_position":42,
		},
		67: {
			"rod_group":23,
			"min_position":36,
			"max_position":42,
		},
		68: {
			"rod_group":24,
			"min_position":30,
			"max_position":36,
		},
		69: {
			"rod_group":20,
			"min_position":8,
			"max_position":12,
		},
		70: {
			"rod_group":17,
			"min_position":16,
			"max_position":20,
		},
		71: {
			"rod_group":25,
			"min_position":12,
			"max_position":16,
		},
		72: {
			"rod_group":21,
			"min_position":12,
			"max_position":16,
		},
	}
}

var group_rods = {
	"sequence_a": {
		1: [
			"26-31",
			"34-39",
			"42-31",
			"34-23",
			"26-15",
			"18-23",
			"10-31",
			"18-39",
			"26-47",
			"42-47",
			"50-39",
			"50-23",
			"42-15",
			"34-07",
			"18-07",
			"10-15",
			"02-23",
			"02-39",
			"10-47",
			"18-55",
			"34-55",
			"58-31",
		],
		2: [
			"34-31",
			"26-23",
			"18-31",
			"26-39",
			"34-47",
			"42-39",
			"50-31",
			"42-23",
			"34-15",
			"18-15",
			"10-23",
			"10-39",
			"18-47",
			"26-55",
			"42-55",
			"50-47",
			"58-39",
			"58-23",
			"50-15",
			"42-07",
			"26-07",
			"02-31",
		],
		3: [
			"30-35",
			"38-27",
			"30-19",
			"22-27",
			"14-35",
			"22-43",
			"30-51",
			"38-43",
			"46-35",
			"54-27",
			"46-19",
			"38-11",
			"22-11",
			"14-19",
			"06-27",
			"06-43",
			"14-51",
			"22-59",
			"38-59",
			"46-51",
			"54-43",
			"30-03",
		],
		4: [
			"30-27",
			"22-35",
			"30-43",
			"38-35",
			"46-27",
			"38-19",
			"30-11",
			"22-19",
			"14-27",
			"14-43",
			"22-51",
			"38-51",
			"46-43",
			"54-35",
			"54-19",
			"46-11",
			"38-03",
			"22-03",
			"14-11",
			"06-19",
			"06-35",
			"30-59",
		],
		5: [
			"58-43",
			"42-03",
			"02-19",
			"18-59",
			"58-19",
			"18-03",
			"02-43",
			"42-59",
		],
		6: [
			"50-11",
			"10-11",
			"10-51",
			"50-51",
		], 
		7: [
			"42-19",
			"18-19",
			"18-43",
			"42-43",
		],
		8: [
			"34-27",
			"26-27",
			"26-35",
			"34-35",
		],
		9: [
			"34-03",
			"02-27",
			"26-59",
			"58-35",
			"26-03",
			"02-35",
			"34-59",
			"58-27",
		],
		10: [
			"14-07",
			"06-47",
			"46-55",
			"54-15",
			"06-15",
			"14-55",
			"54-47",
			"46-07",
		],
		11: [
			"18-27",
			"26-43",
			"42-35",
			"34-19",
			"18-35",
			"34-43",
			"42-27",
			"26-19",
		],
		12: [
			"18-11",
			"10-43",
			"42-51",
			"50-19",
			"42-11",
			"10-19",
			"18-51",
			"50-43",
		],
		13: [
			"26-11",
			"10-35",
			"34-51",
			"50-27",
			"34-11",
			"10-27",
			"26-51",
			"50-35",
		],
		14: [
			"22-47|22",
			"46-39|22",
			"38-15|22",
			"14-23|22",
			"22-15|23",
			"14-39|23",
			"38-47|23",
			"46-23|23",
		],
		15: [
			"30-23|24",
			"22-31|24",
			"30-39|24",
			"38-31|24",
		],
		16: [
			"30-07",
			"06-31",
			"30-55",
			"54-31",
		],
		17: [
			"14-15",
			"14-47",
			"46-47",
			"46-15",
		],
		18: [
			"30-31",
			"22-39",
			"38-39",
			"38-23",
			"22-23",
		],
		19: [
			"22-07|25",
			"06-39|25",
			"38-55|25",
			"54-23|25",
			"38-07|21",
			"06-23|21",
			"22-55|21",
			"54-39|21",
		],
		20: [
			"14-31",
			"30-15",
			"46-31",
			"30-47",
		],
		21: [
			"38-07",
			"06-23",
			"22-55",
			"54-39",
		],
		22: [
			"22-47",
			"46-39",
			"38-15",
			"14-23",
		],
		23: [
			"22-15",
			"14-39",
			"38-47",
			"46-23",
		],
		24: [
			"30-23",
			"22-31",
			"30-39",
			"38-31",
		],
		25: [
			"22-07",
			"06-39",
			"38-55",
			"54-23",
		],
	},
}
