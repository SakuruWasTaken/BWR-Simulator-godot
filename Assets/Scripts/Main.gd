extends Node3D

var starting_rwm_group = 1

var selected_cr = "02-19"
var control_rods = {}
var moving_rods = []
var cr_direction = cr_directions.NOT_MOVING
var cr_continuous_mode = cr_continuous_modes.NOT_MOVING
var cr_target_insertion = 0
var cr_previous_insertion = 0
var cr_drift_test = false
var scram_timer = -1
var scram_all_rods_in = false


# TODO: add enums for the block reason
var rod_withdraw_block = []
var rod_insert_block = []

enum cr_directions {
	NOT_MOVING,
	INSERT,
	WITHDRAW,
	SETTLE
}

enum cr_continuous_modes {
	NOT_MOVING,
	INSERTING,
	WITHDRAWING
}

enum scram_types {
	MANUAL,
	MODE_SHUTDOWN,
}

enum reactor_modes {
	SHUTDOWN,
	REFUEL,
	STARTUP,
	RUN,
}

var reactor_mode = reactor_modes.SHUTDOWN
var reactor_mode_shutdown_bypass = true
var reactor_mode_shutdown_timer = 0

var scram_active = false
var scram_type

var scram_breakers = {}

var average_power_range_monitors = {
	"A": 0.00,
	"B": 0.00,
	"C": 0.00,
	"D": 0.00,
}
var local_power_range_monitors = {}
var intermidiate_range_monitors = {
	"A": {
		"scale": 1,
		"power": 0.00,
		"adjusted_power": 0.00,
	},
	"B": {
		"scale": 1,
		"power": 0.00,
		"adjusted_power": 0.00,
	},
	"C": {
		"scale": 1,
		"power": 0.00,
		"adjusted_power": 0.00,
	},
	"D": {
		"scale": 1,
		"power": 0.00,
		"adjusted_power": 0.00,
	},
	"E": {
		"scale": 1,
		"power": 0.00,
		"adjusted_power": 0.00,
	},
	"F": {
		"scale": 1,
		"power": 0.00,
		"adjusted_power": 0.00,
	},
	"G": {
		"scale": 1,
		"power": 0.00,
		"adjusted_power": 0.00,
	},
	"H": {
		"scale": 1,
		"power": 0.00,
		"adjusted_power": 0.00,
	},
}

@onready var manual_scram_pb_materials = {
	"A1": $"Control Room Panels/Main Panel Center/Controls/SCRAM 1/switches/A1/CSGCylinder3D/Node3D/CSGCylinder3D3".get_material(),
	"B1": $"Control Room Panels/Main Panel Center/Controls/SCRAM 1/switches/B1/CSGCylinder3D/Node3D/CSGCylinder3D3".get_material(),
	"A2": $"Control Room Panels/Main Panel Center/Controls/SCRAM 2/switches/A2/CSGCylinder3D/Node3D/CSGCylinder3D3".get_material(),
	"B2": $"Control Room Panels/Main Panel Center/Controls/SCRAM 2/switches/B2/CSGCylinder3D/Node3D/CSGCylinder3D3".get_material(),
}	

func generate_control_rods():
	var x = 18
	var y = 59
	var rods_to_generate = 0
	var rods_generated_row = 0
	var rods_generated_total = 0

	# our reactor has a total of 185 rods
	while rods_generated_total < 185:
		# calculate how many control rods we need for each row, 
		# and our starting position on y (as the rods in a BWR core are in a circular pattern)
		if y == 59 or y == 3:
			rods_to_generate = 7
			x = 18
		elif y == 55 or y == 7:
			rods_to_generate = 9
			x = 14
		elif y == 51 or y == 11:
			rods_to_generate = 11
			x = 10
		elif y == 47 or y == 15:
			rods_to_generate = 13
			x = 6
		elif y <= 43 and y >= 19:
			rods_to_generate = 15
			x = 2

		while x <= 58 and y <= 59:
			# create rods
			while rods_generated_row < rods_to_generate:
				# there's probably a better way to do this...
				var x_str = str(x)
				if len(x_str) < 2:
					x_str = "0%s" % x_str

				var y_str = str(y)
				if len(y_str) < 2:
					y_str = "0%s" % y_str

				var rod_number = "%s-%s" % [x_str, y_str]
				
				var accum_node = get_node("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/%s/ACCUM_SCRAM_IND/ACCUM" % rod_number)
				var accum_material = accum_node.get_material()
				var scram_node = get_node("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/%s/ACCUM_SCRAM_IND/SCRAM" % rod_number)
				var scram_material = scram_node.get_material()
				var full_out_node = get_node("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/%s/FULL_IN_OUT_IND/FULL OUT" % rod_number)
				var full_out_material = full_out_node.get_material()
				var full_in_node = get_node("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/%s/FULL_IN_OUT_IND/FULL IN" % rod_number)
				var full_in_material = full_in_node.get_material()
				var drift_node = get_node("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/%s/ROD_DRIFT_IND/DRIFT" % rod_number)
				var drift_material = drift_node.get_material()

				control_rods[rod_number] = {
						"cr_insertion": 0.00,
						"cr_scram": false,
						"cr_accum_trouble": false,
						"cr_accum_trouble_acknowledged": true,
						"cr_drift_alarm": false,
						# simulates the effect of some rods being slightly faster or slower than others
						"cr_scram_insertion_speed": randf_range(2.15, 2.31),
						"cr_full_core_display_nodes":
						{
							"accum": {
								"node": accum_node,
								"material": accum_material,
							},
							"scram": {
								"node": scram_node,
								"material": scram_material,
							},
							"full_in": {
								"node": full_in_node,
								"material": full_in_material,
							},
							"full_out": {
								"node": full_out_node,
								"material": full_out_material,
							},
							"drift": {
								"node": drift_node,
								"material": drift_material,
							}
							
						}
				}
				# increment y by 4 because we only have a control rod per every four fuel assemblies
				x += 4

				# keep track of how many rods we're generating
				rods_generated_row += 1
				rods_generated_total += 1

			# move on to the next row
			rods_generated_row = 0
			y -= 4
			break

func _ready():
	var lprm_number = 1
	while lprm_number <= 43:
		local_power_range_monitors[lprm_number] = {
			"D": {
					"power": 0.00,
					
					# TODO: iirc this is adjustable in real life, verify this
					"upscale_setpoint": 117.00,
					
					"full_core_display_downscale_light": get_node("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/LPRM %s/D DOWNSCALE" % [lprm_number]).get_material(),
					"full_core_display_upscale_light": get_node("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/LPRM %s/D UPSCALE" % [lprm_number]).get_material()
			},
			"C": {
					"power": 0.00,
					"upscale_setpoint": 117.00,
					"full_core_display_downscale_light": get_node("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/LPRM %s/C DOWNSCALE" % [lprm_number]).get_material(),
					"full_core_display_upscale_light": get_node("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/LPRM %s/C UPSCALE" % [lprm_number]).get_material()
			},
			"B": {
					"power": 0.00,
					"upscale_setpoint": 117.00,
					"full_core_display_downscale_light": get_node("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/LPRM %s/B DOWNSCALE" % [lprm_number]).get_material(),
					"full_core_display_upscale_light": get_node("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/LPRM %s/B UPSCALE" % [lprm_number]).get_material()
			},
			"A": {
					"power": 0.00,
					"upscale_setpoint": 117.00,
					"full_core_display_downscale_light": get_node("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/LPRM %s/A DOWNSCALE" % [lprm_number]).get_material(),
					"full_core_display_upscale_light": get_node("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/LPRM %s/A UPSCALE" % [lprm_number]).get_material()
			},
		}
		lprm_number += 1
	generate_control_rods()
	for group_number in $"Control Room Panels/Main Panel Center/Meters/RWM Box".groups["sequence_a"]:
		if group_number >= starting_rwm_group:
			break
		var group_info = $"Control Room Panels/Main Panel Center/Meters/RWM Box".groups["sequence_a"][group_number]
		for rod_number in $"Control Room Panels/Main Panel Center/Meters/RWM Box".group_rods["sequence_a"][group_info["rod_group"]]:
			if "|" in rod_number:
				rod_number = rod_number.split("|")[0]
			control_rods[rod_number]["cr_insertion"] = float(group_info["max_position"])

#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(Engine.get_frames_per_second())
	pass

func open_scram_breakers(reason):
	scram_breakers["A1"] = reason
	scram_breakers["A2"] = reason
	scram_breakers["B1"] = reason
	scram_breakers["B2"] = reason
	
func main_loop_timer_expire():
	# mode switch shutdown scram logic
	if reactor_mode == reactor_modes.SHUTDOWN and not reactor_mode_shutdown_bypass and not scram_active:
		reactor_mode_shutdown_timer = 100
		open_scram_breakers(scram_types.MODE_SHUTDOWN)
	elif reactor_mode == reactor_modes.SHUTDOWN and scram_active and reactor_mode_shutdown_bypass != true:
		reactor_mode_shutdown_timer -= 1
		if reactor_mode_shutdown_timer == 0:
			reactor_mode_shutdown_bypass = true
	elif reactor_mode != reactor_modes.SHUTDOWN and reactor_mode_shutdown_bypass:
		reactor_mode_shutdown_bypass = false
	
	# apply rod withdraw blocks
	if reactor_mode == reactor_modes.SHUTDOWN:
		add_new_block("Mode Switch in Shutdown","withdraw_block")
	else:
		add_new_block("Mode Switch in Shutdown","r_withdraw_block")
		
	var irm_downscale = false
	for irm_number in intermidiate_range_monitors:
		if intermidiate_range_monitors[irm_number]["adjusted_power"] < 5 and not intermidiate_range_monitors[irm_number]["scale"] == 1:
			irm_downscale = true
			break
			
	if irm_downscale:
		add_new_block("IRM Downscale","withdraw_block")
	else:
		add_new_block("IRM Downscale","r_withdraw_block")
		
	
	for rod_number in control_rods:
		var rod_info = control_rods[rod_number]
		# detect rods in odd numbered positions (drifting)
		if int(rod_info["cr_insertion"]) % 2 == 1 and (rod_number not in moving_rods or (cr_drift_test or scram_active)):
			control_rods[rod_number]["cr_drift_alarm"] = true
			control_rods[rod_number]["cr_drift_alarm_acknowledged"] = false

func main_loop_timer_fast_expire():
	if scram_breakers != {}:
		var rps_a_scram = "A1" in scram_breakers or "A2" in scram_breakers
		var rps_b_scram = "B1" in scram_breakers or "B2" in scram_breakers
		var full_scram = rps_a_scram and rps_b_scram
		
		if rps_a_scram:
			if not "A1" in scram_breakers:
				scram_breakers["A1"] = scram_breakers["A2"]
			elif not "A2" in scram_breakers:
				scram_breakers["A2"] = scram_breakers["A1"]
		
		if rps_b_scram:
			if not "B1" in scram_breakers:
				scram_breakers["B1"] = scram_breakers["B2"]
			elif not "B2" in scram_breakers:
				scram_breakers["B2"] = scram_breakers["B1"]
				
		manual_scram_pb_materials["A1"].emission_enabled = false
		manual_scram_pb_materials["A2"].emission_enabled = false
		manual_scram_pb_materials["B1"].emission_enabled = false
		manual_scram_pb_materials["B2"].emission_enabled = false
		
		for breaker in scram_breakers:
			manual_scram_pb_materials[breaker].emission_enabled = true
		
		if full_scram:
			if not scram_active:
				var set_scram_reset_light_on = false
				scram(scram_types.MANUAL)
				while scram_active == true:
					if scram_timer >= 1:
						scram_timer -= 1
					elif set_scram_reset_light_on == false:
						set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Reset SCRAM", true)
						# small optimisation so we're not constantly getting the material and causing a bunch of lag
						set_scram_reset_light_on = true
					await get_tree().create_timer(0.1).timeout

func add_new_block(type,act):
	if act == "withdraw_block":
		if type not in rod_withdraw_block:
			rod_withdraw_block.append(type)
		$"Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/WithdrawBlock_lt".get_material().emission_enabled = true
	elif act == "insert_block":
		if type not in rod_insert_block:
			rod_insert_block.append(type)
		$"Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/InsertBlock_lt".get_material().emission_enabled = true
	elif act == "r_withdraw_block":
		if type in rod_withdraw_block:
			rod_withdraw_block.erase(type)
		if rod_withdraw_block == []:
			$"Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/WithdrawBlock_lt".get_material().emission_enabled = false
	elif act == "r_insert_block":
		if type in rod_insert_block:
			rod_insert_block.erase(type)
		if rod_insert_block == []:
			$"Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/InsertBlock_lt".get_material().emission_enabled = false


func calculate_vertical_scale_position(indicated_value, scale_max, meter_min_position = 0.071, meter_max_position = -0.071):
	return clamp((((scale_max - indicated_value)/(scale_max/(meter_min_position*2))) - meter_min_position), meter_max_position, meter_min_position)

func make_string_two_digit(string):
	if len(string) == 1:
		return "0%s" % string
	return string
	

func set_object_emission(object, state):
	var node = get_node(object)
	var material = node.get_material()
	material.emission_enabled = state
	
func set_rod_light_emission(rod_number, light, state):
	control_rods[rod_number]["cr_full_core_display_nodes"][light]["material"].emission_enabled = state
	
func change_selected_rod(rod):
	if moving_rods == []:
		set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Rod Selectors/%s" % selected_cr, false)
		set_object_emission("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/%s/ROD_DRIFT_IND/ROD" % selected_cr, false)
		selected_cr = rod
		set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Rod Selectors/%s" % selected_cr, true)
		set_object_emission("Control Room Panels/Main Panel Center/Full Core Display/full core display lights/%s/ROD_DRIFT_IND/ROD" % selected_cr, true if not $"Control Room Panels/Main Panel Center/Full Core Display/full core display lights".rpis_inop else false)
		$"Control Room Panels/Main Panel Center/Rod Position Monitors".selected_rod_changed(selected_cr)

func rod_selector_pressed(camera, event, position, normal, shape_idx, parent_object):
	change_selected_rod(parent_object.name)
	
func scram(type):
	scram_type = type
	add_new_block("SCRAM","withdraw_block")
	var rods_in = 0
	while rods_in < 185:
		rods_in = 0
		for rod_number in control_rods:
			scram_active = true
			var rod_info = control_rods[rod_number]
			var cr_insertion = rod_info["cr_insertion"]
			var cr_accum_trouble = rod_info["cr_accum_trouble"]
			var cr_accum_trouble_acknowledged = rod_info["cr_accum_trouble_acknowledged"]

			if scram_timer == -1:
				scram_timer = 120
			elif scram_timer < 106:
				cr_accum_trouble = true
				cr_accum_trouble_acknowledged = false
			if cr_insertion != 0:
				if scram_timer < 114:
					if not rod_number in moving_rods:
						moving_rods.append(rod_number)
					# TODO: insertion time changes with RPV pressure and CRD system/accumulator pressure
					# the time from full out to full in is around ~2.6 seconds
					cr_insertion -= rod_info["cr_scram_insertion_speed"]
					if cr_insertion <= 0:
						cr_insertion = 0
			else:
				if rod_number in moving_rods:
					moving_rods.erase(rod_number)
				rods_in += 1
				

			control_rods[rod_number].cr_insertion=cr_insertion
			control_rods[rod_number].cr_scram=true
			control_rods[rod_number].cr_accum_trouble=cr_accum_trouble
			control_rods[rod_number].cr_accum_trouble_acknowledged=cr_accum_trouble_acknowledged
		await get_tree().create_timer(0.1).timeout

	scram_all_rods_in = true

func withdraw_selected_cr():
	if rod_withdraw_block != [] or cr_direction != 0:
		return

	var rod = selected_cr
	var insertion = control_rods[rod]["cr_insertion"]
	var correct_insertion = insertion
	cr_target_insertion = insertion + 2

	# TODO: rod overtravel check
	if int(insertion) >= 48:
		return
		
	# time delay to unlatch control
	await get_tree().create_timer(randf_range(0.00, 0.04)).timeout
	moving_rods.append(rod)
	cr_previous_insertion = insertion
	cr_direction = cr_directions.INSERT
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Insert_lt", true)
		
	# insert (unlatch) for 0.6 seconds before withdrawal
	var runs = 0
	while runs < 6 and not scram_active: 
		insertion -= 0.082
		control_rods[rod].cr_insertion=insertion
		await get_tree().create_timer(randf_range(0.085, 0.115)).timeout
		runs += 1

	cr_direction = cr_directions.NOT_MOVING
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Insert_lt", false)
	
	await get_tree().create_timer(randf_range(0, 0.15)).timeout
	
	cr_direction = cr_directions.WITHDRAW
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Withdraw_lt", true)
	
	# withdraw for 1.5 seconds
	runs = 0
	while runs < 15 and not scram_active: 
		insertion += 0.144
		
		control_rods[rod].cr_insertion=insertion
		await get_tree().create_timer(randf_range(0.090, 0.11)).timeout
		runs += 1
		
	cr_direction = cr_directions.SETTLE
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Withdraw_lt", false)
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Settle_lt", true)

	# TODO: simulate switching overlap between withdraw control and settle control

	# let the rod settle into the notch
	runs = 0
	
	while runs < 60 and not scram_active: 
		if insertion >= cr_target_insertion:
			insertion = cr_target_insertion
		else:
			insertion += 0.0064
		control_rods[rod].cr_insertion=insertion
		await get_tree().create_timer(randf_range(0.090, 0.11)).timeout
		runs += 1
	if not scram_active:
		control_rods[rod].cr_insertion=cr_target_insertion
		moving_rods.erase(rod)
		
	cr_direction = cr_directions.NOT_MOVING
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Settle_lt", false)

func insert_selected_cr():
	if rod_insert_block != [] or cr_direction != 0:
		return

	var rod = selected_cr
	var insertion = control_rods[rod]["cr_insertion"]
	var correct_insertion = insertion
	cr_target_insertion = insertion - 2
	
	if int(insertion) <= 0:
		return
		
	# time delay to insert control
	await get_tree().create_timer(randf_range(0.00, 0.04)).timeout
	moving_rods.append(rod)
	cr_previous_insertion = insertion
	cr_direction = cr_directions.INSERT
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Insert_lt", true)
		
	# insert for 2.9 seconds
	var runs = 0
	while runs < 29 and not self.scram_active: 
		insertion -= 0.082
		control_rods[rod].cr_insertion=insertion
		await get_tree().create_timer(randf_range(0.090, 0.11)).timeout
		runs += 1

	cr_direction = cr_directions.NOT_MOVING
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Insert_lt", false)
	
	await get_tree().create_timer(randf_range(0, 0.15)).timeout
	
	cr_direction = cr_directions.SETTLE
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Settle_lt", true)

	# let the rod settle into the notch
	runs = 0
	while runs < 53 and not scram_active: 
		if insertion >= cr_target_insertion:
			insertion = cr_target_insertion
		else:
			insertion += 0.0076
		
		control_rods[rod].cr_insertion=insertion
		await get_tree().create_timer(randf_range(0.090, 0.11)).timeout
		runs += 1
		
	if not scram_active:
		control_rods[rod].cr_insertion=cr_target_insertion
		moving_rods.erase(rod)
		
	cr_direction = cr_directions.NOT_MOVING
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Settle_lt", false)

func continuous_withdraw_selected_cr():
	if rod_withdraw_block != [] or cr_direction != 0:
		return

	var rod = selected_cr
	var insertion = control_rods[rod]["cr_insertion"]
	var correct_insertion = insertion

	# TODO: rod overtravel check
	if int(insertion) >= 48:
		return
	cr_continuous_mode = cr_continuous_modes.WITHDRAWING
	# time delay to unlatch control
	await get_tree().create_timer(randf_range(0.00, 0.04)).timeout
	moving_rods.append(rod)
	cr_target_insertion = insertion + 2
	cr_previous_insertion = insertion
	cr_direction = cr_directions.INSERT
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Insert_lt", true)
		
	# insert (unlatch) for 0.6 seconds before withdrawal
	var runs = 0
	while runs < 6 and not scram_active: 
		insertion -= 0.082
		control_rods[rod].cr_insertion=insertion
		await get_tree().create_timer(randf_range(0.085, 0.115)).timeout
		runs += 1

	cr_direction = cr_directions.NOT_MOVING
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Insert_lt", false)
	
	await get_tree().create_timer(randf_range(0, 0.15)).timeout
	
	cr_direction = cr_directions.WITHDRAW
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 1/Lights and buttons/ContWithdraw_lt", true)
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Withdraw_lt", true)
	
	# withdraw for 1.4 seconds each cycle
	while cr_continuous_mode == 2 and rod_withdraw_block == [] and not scram_active and cr_target_insertion <= 46 or cr_target_insertion == 48:
		runs = 0
		while runs < 14 and not self.scram_active: 
			insertion += 0.1435
			control_rods[rod].cr_insertion=insertion
			await get_tree().create_timer(randf_range(0.090, 0.11)).timeout
			runs += 1

		cr_previous_insertion = cr_target_insertion

		if rod_withdraw_block == [] and not scram_active and cr_continuous_mode == cr_continuous_modes.WITHDRAWING and cr_target_insertion != 48:
			cr_target_insertion += 2
		else:
			break
			
	cr_previous_insertion = cr_target_insertion
	cr_direction = cr_directions.SETTLE
	cr_continuous_mode = cr_continuous_modes.NOT_MOVING
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 1/Lights and buttons/ContWithdraw_lt", false)
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Withdraw_lt", false)
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Settle_lt", true)

	# TODO: simulate switching overlap between withdraw control and settle control

	# let the rod settle into the notch
	runs = 0
	while runs < 60 and not scram_active: 
		if insertion >= cr_target_insertion:
			insertion = cr_target_insertion
		else:
			insertion += 0.0070
		
		control_rods[rod].cr_insertion=insertion
		await get_tree().create_timer(randf_range(0.090, 0.11)).timeout
		runs += 1
	
	if not scram_active:
		control_rods[rod].cr_insertion=cr_target_insertion
		moving_rods.erase(rod)
		
	cr_direction = cr_directions.NOT_MOVING
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Settle_lt", false)
	
		
func continuous_insert_selected_cr():
	if rod_insert_block != [] or cr_direction != 0:
		return

	var rod = selected_cr
	var insertion = control_rods[rod]["cr_insertion"]
	var correct_insertion = insertion

	# TODO: rod overtravel check
	if int(insertion) <= 0:
		return
		
	# time delay to unlatch control
	cr_continuous_mode = cr_continuous_modes.INSERTING
	await get_tree().create_timer(randf_range(0.00, 0.04)).timeout
	moving_rods.append(rod)
	cr_target_insertion = insertion - 2
	cr_previous_insertion = insertion
	cr_direction = cr_directions.INSERT
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Insert_lt", true)
	
	# withdraw for 1.4 seconds each cycle
	while cr_continuous_mode == cr_continuous_modes.INSERTING and rod_insert_block == [] and not scram_active and cr_target_insertion >= 2 or cr_target_insertion == 0:
		var runs = 0
		while runs < 24 and not self.scram_active: 
			insertion -= 0.0832
			control_rods[rod].cr_insertion=insertion
			await get_tree().create_timer(randf_range(0.090, 0.11)).timeout
			runs += 1

		cr_previous_insertion = cr_target_insertion

		if rod_insert_block == [] and not scram_active and cr_continuous_mode == cr_continuous_modes.INSERTING and cr_target_insertion != 0:
			cr_target_insertion -= 2
		else:
			break
			
	# move the rod a tiny bit further for settle
	# TODO: is this realistic?
	if not self.scram_active:
		var runs = 0
		while runs < 4 and not scram_active: 
			insertion -= 0.082
			control_rods[rod].cr_insertion=insertion
			await get_tree().create_timer(randf_range(0.090, 0.11)).timeout
			runs += 1
			
	cr_previous_insertion = cr_target_insertion
	cr_direction = cr_directions.SETTLE
	cr_continuous_mode = cr_continuous_modes.NOT_MOVING
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Insert_lt", false)
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Settle_lt", true)

	# let the rod settle into the notch
	var runs = 0
	while runs < 53 and not scram_active: 
		if insertion >= cr_target_insertion:
			insertion = cr_target_insertion
		else:
			insertion += 0.0076
		
		control_rods[rod].cr_insertion=insertion
		await get_tree().create_timer(randf_range(0.090, 0.11)).timeout
		runs += 1

	if not scram_active:
		control_rods[rod].cr_insertion=cr_target_insertion
		moving_rods.erase(rod)
		
	cr_direction = cr_directions.NOT_MOVING
	set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Settle_lt", false)

func rod_motion_button_pressed(parent, pressed):
	if pressed == true and parent.name in ["A1", "A2", "B1", "B2"]:
		scram_breakers[parent.name] = scram_types.MANUAL
	elif parent.name == "Withdraw_pb":
		if pressed == true:
			withdraw_selected_cr()
	elif parent.name == "Insert_pb":
		if pressed == true:
			insert_selected_cr()
	elif parent.name == "ContWithdraw_pb":
		if pressed == true:
			continuous_withdraw_selected_cr()
		else:
			cr_continuous_mode = cr_continuous_modes.NOT_MOVING
	elif parent.name == "ContInsert_pb":
		if pressed == true:
			continuous_insert_selected_cr()
		else:
			cr_continuous_mode = cr_continuous_modes.NOT_MOVING
	elif parent.name == "Reset SCRAM":
		if not scram_active:
			scram_breakers = {}
			manual_scram_pb_materials["B1"].emission_enabled = false
			manual_scram_pb_materials["B2"].emission_enabled = false
			manual_scram_pb_materials["A1"].emission_enabled = false
			manual_scram_pb_materials["A2"].emission_enabled = false
		if scram_active and self.scram_timer == 0 and pressed:
			set_object_emission("Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Panel 2/Lights and buttons/Reset SCRAM", false)
			scram_all_rods_in = false
			scram_active = false
			scram_timer = -1
			scram_breakers = {}
			manual_scram_pb_materials["B1"].emission_enabled = false
			manual_scram_pb_materials["B2"].emission_enabled = false
			manual_scram_pb_materials["A1"].emission_enabled = false
			manual_scram_pb_materials["A2"].emission_enabled = false
			for rod_number in control_rods:
				control_rods[rod_number].cr_scram = false
				control_rods[rod_number].cr_accum_trouble = false
			add_new_block("SCRAM","r_withdraw_block")
		
	elif parent.name == "DriftTest_pb":
		cr_drift_test = pressed
	elif parent.name == "DriftReset_pb":
		if pressed == true:
			for rod_number in control_rods:
				control_rods[rod_number]["cr_drift_alarm"] = false
	elif parent.name == "AccumAck_pb":
		for rod_number in control_rods:
			control_rods[rod_number].cr_accum_trouble_acknowledged = true
