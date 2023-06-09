extends Node3D
@onready var node_3d = $"/root/Node3d"

var selected_group = 1

var select_groups = {
	1: {
		1: "06-23",
		2: "02-23",
		3: "06-19",
		4: "02-19",
	},
	2: {
		1: "14-23",
		2: "10-23",
		3: "14-19",
		4: "10-19",
	},
	3: {
		1: "22-23",
		2: "18-23",
		3: "22-19",
		4: "18-19",
	},
	4: {
		1: "30-23",
		2: "26-23",
		3: "30-19",
		4: "26-19",
	},
	5: {
		1: "38-23",
		2: "34-23",
		3: "38-19",
		4: "34-19",
	},
	6: {
		1: "46-23",
		2: "42-23",
		3: "46-19",
		4: "42-19",
	},
	7: {
		1: "54-23",
		2: "50-23",
		3: "54-19",
		4: "50-19",
	},
	8: {
		1: "none",
		2: "58-23",
		3: "none",
		4: "58-19",
	},
	9: {
		1: "06-31",
		2: "02-31",
		3: "06-27",
		4: "02-27",
	},
	10: {
		1: "14-31",
		2: "10-31",
		3: "14-27",
		4: "10-27",
	},
	11: {
		1: "22-31",
		2: "18-31",
		3: "22-27",
		4: "18-27",
	},
	12: {
		1: "30-31",
		2: "26-31",
		3: "30-27",
		4: "26-27",
	},
	13: {
		1: "38-31",
		2: "34-31",
		3: "38-27",
		4: "34-27",
	},
	14: {
		1: "46-31",
		2: "42-31",
		3: "46-27",
		4: "42-27",
	},
	15: {
		1: "54-31",
		2: "50-31",
		3: "54-27",
		4: "50-27",
	},
	16: {
		1: "none",
		2: "58-31",
		3: "none",
		4: "58-27",
	},
	17: {
		1: "06-39",
		2: "02-39",
		3: "06-35",
		4: "02-35",
	},
	18: {
		1: "14-39",
		2: "10-39",
		3: "14-35",
		4: "10-35",
	},
	19: {
		1: "22-39",
		2: "18-39",
		3: "22-35",
		4: "18-35",
	},
	20: {
		1: "30-39",
		2: "26-39",
		3: "30-35",
		4: "26-35",
	},
	21: {
		1: "38-39",
		2: "34-39",
		3: "38-35",
		4: "34-35",
	},
	22: {
		1: "46-39",
		2: "42-39",
		3: "46-35",
		4: "42-35",
	},
	23: {
		1: "54-39",
		2: "50-39",
		3: "54-35",
		4: "50-35",
	},
	24: {
		1: "none",
		2: "58-39",
		3: "none",
		4: "58-35",
	},
	25: {
		1: "06-47",
		2: "none",
		3: "06-43",
		4: "02-43",
	},
	26: {
		1: "14-47",
		2: "10-47",
		3: "14-43",
		4: "10-43",
	},
	27: {
		1: "22-47",
		2: "18-47",
		3: "22-43",
		4: "18-43",
	},
	28: {
		1: "30-47",
		2: "26-47",
		3: "30-43",
		4: "26-43",
	},
	29: {
		1: "38-47",
		2: "34-47",
		3: "38-43",
		4: "34-43",
	},
	30: {
		1: "46-47",
		2: "42-47",
		3: "46-43",
		4: "42-43",
	},
	31: {
		1: "54-47",
		2: "50-47",
		3: "54-43",
		4: "50-43",
	},
	32: {
		1: "none",
		2: "none",
		3: "none",
		4: "58-43",
	},
	33: {
		1: "14-55",
		2: "none",
		3: "14-51",
		4: "10-51",
	},
	34: {
		1: "22-55",
		2: "18-55",
		3: "22-51",
		4: "18-51",
	},
	35: {
		1: "30-55",
		2: "26-55",
		3: "30-51",
		4: "26-51",
	},
	36: {
		1: "38-55",
		2: "34-55",
		3: "38-51",
		4: "34-51",
	},
	37: {
		1: "46-55",
		2: "42-55",
		3: "46-51",
		4: "42-51",
	},
	38: {
		1: "none",
		2: "none",
		3: "none",
		4: "50-51",
	},
	39: {
		1: "none",
		2: "none",
		3: "22-59",
		4: "18-59",
	},
	40: {
		1: "none",
		2: "none",
		3: "30-59",
		4: "26-59",
	},
	41: {
		1: "none",
		2: "none",
		3: "38-59",
		4: "34-59",
	},
	42: {
		1: "none",
		2: "none",
		3: "none",
		4: "42-59",
	},
	43: {
		1: "14-07",
		2: "none",
		3: "none",
		4: "none",
	},
	44: {
		1: "22-07",
		2: "18-07",
		3: "22-03",
		4: "18-03",
	},
	45: {
		1: "30-07",
		2: "26-07",
		3: "30-03",
		4: "26-03",
	},
	46: {
		1: "38-07",
		2: "34-07",
		3: "38-03",
		4: "34-03",
	},
	47: {
		1: "46-07",
		2: "42-07",
		3: "none",
		4: "42-03",
	},
	48: {
		1: "14-15",
		2: "10-15",
		3: "14-11",
		4: "10-11",
	},
	49: {
		1: "22-15",
		2: "18-15",
		3: "22-11",
		4: "18-11",
	},
	50: {
		1: "30-15",
		2: "26-15",
		3: "30-11",
		4: "26-11",
	},
	51: {
		1: "38-15",
		2: "34-15",
		3: "38-11",
		4: "34-11",
	},
	52: {
		1: "46-15",
		2: "42-15",
		3: "46-11",
		4: "42-11",
	},
	53: {
		1: "06-15",
		2: "none",
		3: "none",
		4: "none",
	},
	54: {
		1: "54-15",
		2: "50-15",
		3: "none",
		4: "50-11",
	},
}

var insertion
var selected_rod_meter_number = 4

# TODO: this is actually not how these indicators work in real life, make these more realistic

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	while true:
#		await get_tree().create_timer(0.1).timeout


func selected_rod_changed(rod):
	node_3d.set_object_emission("Control Room Panels/Main Panel Center/Rod Position Monitors/Rod Position Monitor %s/%s" % [selected_rod_meter_number, selected_rod_meter_number], false)
	var done = false
	if not rod in select_groups[selected_group]:
		for group_number in select_groups:
			var group_info = select_groups[group_number]
			for group_rod_number in group_info:
				var rod_number = group_info[group_rod_number]
				if rod_number == rod:
					selected_group = group_number
					selected_rod_meter_number = group_rod_number
					done = true
					break
			if done:
				# there probably is a better way to do this but i don't know how
				break
	else:
		for group_rod_number in select_groups[selected_group]:
			var rod_number = select_groups[selected_group][group_rod_number]
			if rod_number == rod:
				selected_rod_meter_number = group_rod_number
				break
	node_3d.set_object_emission("Control Room Panels/Main Panel Center/Rod Position Monitors/Rod Position Monitor %s/%s" % [selected_rod_meter_number, selected_rod_meter_number], true)


func _on_timer_timeout():
	for monitor in select_groups[selected_group]:
		var final_string
		var rod_number = select_groups[selected_group][monitor]
		if rod_number != "none":
			final_string = ""
			var first_number = true
			if rod_number in node_3d.moving_rods and not node_3d.scram_active:
				insertion = node_3d.cr_previous_insertion
			else:
				insertion = node_3d.control_rods[rod_number]["cr_insertion"]
			for number in node_3d.make_string_two_digit(str(int(insertion))):
				if first_number == true:
					final_string = "%s%s   " % [final_string, number]
				else:
					final_string = "%s%s" % [final_string, number]
				first_number = false
		else:
			final_string = "     "
		get_node("Rod Position Monitor %s/Insertion Text" % monitor).text = final_string
