extends Node3D
@onready var node_3d = $"/root/Node3d"
var thread
var cycles = 0
var insertion
func _ready():
	update_full_core_display()
	
func update_full_core_display():
	while true:
		await get_tree().create_timer(0.1).timeout
		for rod_number in node_3d.control_rods:
			var rod_info = node_3d.control_rods[rod_number]
			if rod_number in node_3d.moving_rods and not node_3d.scram_active:
				insertion = int(node_3d.cr_previous_insertion)
			else:
				insertion = int(node_3d.control_rods[rod_number]["cr_insertion"])
			node_3d.set_rod_light_emission(rod_number, "full_in", insertion == 0)
			node_3d.set_rod_light_emission(rod_number, "full_out", insertion == 48)
			node_3d.set_rod_light_emission(rod_number, "scram",rod_info["cr_scram"])
			node_3d.set_rod_light_emission(rod_number, "drift", rod_info["cr_drift_alarm"])
			
			# 18-59 has a slight offset to avoid it appearing desynced from the rest of the lights
			if node_3d.accum_trouble_ack == false:
				if rod_info["cr_accum_trouble"] and (rod_number == "18-59" or cycles >= 0):
					node_3d.set_rod_light_emission(rod_number, "accum", true if cycles <= 1 else false)
				else:
					node_3d.set_rod_light_emission(rod_number, "accum", false)
			else:
				node_3d.set_rod_light_emission(rod_number, "accum", rod_info["cr_accum_trouble"])
			if cycles >= 3:
				cycles = -1
			
		cycles += 1
			

func _process(delta):
	pass
