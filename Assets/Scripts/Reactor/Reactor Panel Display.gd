extends Node2D

@onready var node_3d = $"/root/Node3d"
@onready var display = $"../Reactor Display"
@onready var rwm = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box"

# Called when the node enters the scene tree for the first time.
func _ready():
	while true:
		# get rods in current RWM group
		var current_group_rods = []
		if !rwm.rwm_inop and !rwm.alarm_displays_blank:
			var group_info = rwm.groups["sequence_a"][rwm.current_group]
			for rod in rwm.group_rods["sequence_a"][group_info["rod_group"]]:
				if "|" in rod:
					rod = rod.split("|")[0]
					
				current_group_rods.append(rod)

		for rod_number in node_3d.control_rods:
			var rod_info = node_3d.control_rods[rod_number]
			var insertion
			if rod_number in node_3d.moving_rods and not node_3d.scram_active:
				insertion = int(node_3d.cr_previous_insertion)
			else:
				insertion = int(node_3d.control_rods[rod_number]["cr_insertion"])
				
			var rod_selected = rod_number == node_3d.selected_cr
			var rod_in_current_group = rod_number in current_group_rods

			var color = Color(1, 1, 0) if rod_selected else Color(0, 1, 0) if insertion == 0 else Color(1, 0, 0) if insertion == 48 else Color(1, 1, 1)
			
			display.get_node("UI/Core Display/Rods/%s" % rod_number).color = color
			display.get_node("UI/Core Display/Rods/%s/Node2D" % rod_number).visible = rod_in_current_group
		await get_tree().create_timer(3).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
