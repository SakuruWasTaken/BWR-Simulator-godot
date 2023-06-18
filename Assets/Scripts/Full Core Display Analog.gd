extends Node3D
@onready var node_3d = $"/root/Node3d"
var thread
var cycles = 0
var insertion
@onready var parent_node = %"Full Core Display"

func initalise_rpis():
	while $"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display".mode == "Analog":
		for rod_number in node_3d.control_rods:
			var rod_info = node_3d.control_rods[rod_number]
			if rod_number in node_3d.moving_rods and not node_3d.scram_active:
				insertion = int(node_3d.cr_previous_insertion)
			else:
				insertion = int(node_3d.control_rods[rod_number]["cr_insertion"])
			node_3d.set_rod_light_emission(rod_number, "full_in", insertion == 0 and not parent_node.rpis_inop)
			node_3d.set_rod_light_emission(rod_number, "full_out", insertion == 48 and not parent_node.rpis_inop)
			node_3d.set_rod_light_emission(rod_number, "scram", rod_info["cr_scram"] and not parent_node.rpis_inop)
			node_3d.set_rod_light_emission(rod_number, "drift", rod_info["cr_drift_alarm"] and not parent_node.rpis_inop)
			
			# 18-59 has a slight offset to avoid it appearing desynced from the rest of the lights
			if node_3d.accum_trouble_ack == false:
				if rod_info["cr_accum_trouble"] and (rod_number == "18-59" or cycles >= 0):
					node_3d.set_rod_light_emission(rod_number, "accum", true if cycles <= 1 and not parent_node.rpis_inop else false)
				else:
					node_3d.set_rod_light_emission(rod_number, "accum", false)
			else:
				node_3d.set_rod_light_emission(rod_number, "accum", rod_info["cr_accum_trouble"] and not parent_node.rpis_inop)
			if cycles >= 3:
				cycles = -1
			
		cycles += 1
		await get_tree().create_timer(0.1).timeout
		
		for lprm_number in node_3d.local_power_range_monitors:
			for detector in node_3d.local_power_range_monitors[lprm_number]:
				node_3d.local_power_range_monitors[lprm_number][detector]["full_core_display_downscale_light"].emission_enabled = true if node_3d.local_power_range_monitors[lprm_number][detector]["power"] < 3 else false
				node_3d.local_power_range_monitors[lprm_number][detector]["full_core_display_upscale_light"].emission_enabled = true if node_3d.local_power_range_monitors[lprm_number][detector]["power"] > node_3d.local_power_range_monitors[lprm_number][detector]["upscale_setpoint"] else false
			
func set_rpis_inop(state):
	node_3d.set_object_emission("Control Room Panels/Main Panel Center/Full Core Display/Analog/full core display lights/%s/ROD_DRIFT_IND/ROD" % node_3d.selected_cr, !state)

func selected_rod_changed(rod_number, previous_selection):
		node_3d.set_object_emission("Control Room Panels/Main Panel Center/Full Core Display/Analog/full core display lights/%s/ROD_DRIFT_IND/ROD" % previous_selection, false)
		node_3d.set_object_emission("Control Room Panels/Main Panel Center/Full Core Display/Analog/full core display lights/%s/ROD_DRIFT_IND/ROD" % rod_number, true if not parent_node.rpis_inop else false)


func _process(delta):
	pass
