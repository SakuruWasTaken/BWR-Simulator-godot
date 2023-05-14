extends CSGCombiner3D
var thread
var cycles = 0
var insertion
# Called when the node enters the scene tree for the first time.
func _ready():
	thread = Thread.new()
	# Third argument is optional userdata, it can be any variable.
	thread.start(update_full_core_display)
	
func update_full_core_display():
	while true:
		await get_tree().create_timer(0.1).timeout
		for rod_number in $"/root/Node3d".control_rods:
			var rod_info = $"/root/Node3d".control_rods[rod_number]
			if rod_number in $"/root/Node3d".moving_rods and not $"/root/Node3d".scram_active:
				insertion = int($"/root/Node3d".cr_previous_insertion)
			else:
				insertion = int($"/root/Node3d".control_rods[rod_number]["cr_insertion"])
			$"/root/Node3d".set_object_emission("Control Room Panels/full core display lights/%s/FULL_IN_OUT_IND/FULL IN" % rod_number, insertion == 0)
			$"/root/Node3d".set_object_emission("Control Room Panels/full core display lights/%s/FULL_IN_OUT_IND/FULL OUT" % rod_number, insertion == 48)
				
			$"/root/Node3d".set_object_emission("Control Room Panels/full core display lights/%s/ACCUM_SCRAM_IND/SCRAM" % rod_number, rod_info["cr_scram"])
			# 02-19 has a slight offset to avoid it appearing desynced from the rest of the lights
			if rod_info["cr_accum_trouble"] and (rod_number == "02-19" or cycles >= 0):
				$"/root/Node3d".set_object_emission("Control Room Panels/full core display lights/%s/ACCUM_SCRAM_IND/ACCUM" % rod_number, true if cycles <= 2 else false)
			else:
				$"/root/Node3d".set_object_emission("Control Room Panels/full core display lights/%s/ACCUM_SCRAM_IND/ACCUM" % rod_number, false)
			if cycles >= 5:
				cycles = -1
			
			$"/root/Node3d".set_object_emission("Control Room Panels/full core display lights/%s/ROD_DRIFT_IND/DRIFT" % rod_number, rod_info["cr_drift_alarm"])
		cycles += 1
		#queue_free() 
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
