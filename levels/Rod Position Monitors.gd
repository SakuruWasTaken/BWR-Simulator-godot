extends Node3D

var selected_monitor = 1

var selected_rods = {
	1: "02-19",
	2: "02-23",
	3: "06-19",
	4: "06-23"
}

var insertion

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	while true:
		await get_tree().create_timer(0.1).timeout
		for monitor in selected_rods:
			var rod_number = selected_rods[monitor]
			var final_string = ""
			var first_number = true
			if rod_number in $"/root/Node3d".moving_rods and not $"/root/Node3d".scram_active:
				insertion = $"/root/Node3d".cr_previous_insertion
			else:
				insertion = $"/root/Node3d".control_rods[rod_number]["cr_insertion"]
			for number in $"/root/Node3d".make_string_two_digit(str(int(insertion))):
				if first_number == true:
					final_string = "%s%s   " % [final_string, number]
				else:
					final_string = "%s%s" % [final_string, number]
				first_number = false
			get_node("Rod Position Monitor %s/Insertion Text" % monitor).text = final_string

func select_rod_button_pressed(parent):
	$"/root/Node3d".set_object_emission("Control Room Panels/Main Panel Center/Rod Position Monitors/Rod Position Monitor %s/%s" % [selected_monitor, selected_monitor], false)
	selected_monitor = int(str(parent.name))
	selected_rods[selected_monitor] = $"/root/Node3d".selected_cr
	$"/root/Node3d".set_object_emission("Control Room Panels/Main Panel Center/Rod Position Monitors/Rod Position Monitor %s/%s" % [selected_monitor, selected_monitor], true)
