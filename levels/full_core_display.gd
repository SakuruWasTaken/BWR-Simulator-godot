extends Node3D
var thread
var cycles = 0
var insertion
func _ready():
	update_full_core_display()
	
func update_full_core_display():
	while true:
		await get_tree().create_timer(0.1).timeout
		for rod_number in $"/root/Node3d".control_rods:
			var rod_info = $"/root/Node3d".control_rods[rod_number]
			if rod_number in $"/root/Node3d".moving_rods and not $"/root/Node3d".scram_active:
				insertion = int($"/root/Node3d".cr_previous_insertion)
			else:
				insertion = int($"/root/Node3d".control_rods[rod_number]["cr_insertion"])
			$"/root/Node3d".set_rod_light_emission(rod_number, "full_in", insertion == 0)
			$"/root/Node3d".set_rod_light_emission(rod_number, "full_out", insertion == 48)
			$"/root/Node3d".set_rod_light_emission(rod_number, "scram",rod_info["cr_scram"])
			$"/root/Node3d".set_rod_light_emission(rod_number, "drift", rod_info["cr_drift_alarm"])
			
			# 18-59 has a slight offset to avoid it appearing desynced from the rest of the lights
			if rod_info["cr_accum_trouble"] and (rod_number == "18-59" or cycles >= 0):
				$"/root/Node3d".set_rod_light_emission(rod_number, "accum", true if cycles <= 1 else false)
			else:
				$"/root/Node3d".set_rod_light_emission(rod_number, "accum", false)
			if cycles >= 3:
				cycles = -1
			
		cycles += 1
			

func _process(delta):
	pass
