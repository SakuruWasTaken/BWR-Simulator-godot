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
var scram_all_rods_in = false
var mode_switch_shutdown_timer = -1

var rps = {
	"a": {
		"trip": false,
		"reset_permit": false,
		"trip_timer": -1,
		"reasons": {},
		"bypasses": {
			"mode_switch_shutdown": true,
		},
	},
	"b": {
		"trip": false,
		"reset_permit": false,
		"trip_timer": -1,
		"reasons": {},
		"bypasses": {
			"mode_switch_shutdown": true,
		},
	},
}


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

var scram_active = false
var scram_type

var scram_breakers = {}

var source_range_monitors = {
	"A": {
		"bypassed": false,
		"retraction": 0,
		"value": 0,
		"period": -9999.00,
	},
	"B": {
		"bypassed": false,
		"retraction": 0,
		"value": 0,
		"period": -9999.00,
	},
	"C": {
		"bypassed": false,
		"retraction": 0,
		"value": 0,
		"period": -9999.00,
	},
	"D": {
		"bypassed": false,
		"retraction": 0,
		"value": 0,
		"period": -9999.00,
	},
}

var average_power_range_monitors = {
	"A": 0.00,
	"B": 0.00,
	"C": 0.00,
	"D": 0.00,
	"E": 0.00,
	"F": 0.00,
}
var local_power_range_monitors = {}
var intermediate_range_monitors = {
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

var chart_recorders = {
	"srm_chart_recorder": {
		"values": {
			1: {
				"name": "SRM A - C",
				"color": Color(1, 0, 0),
				"unit": "CPS",
				"value_source": "func",
				"func": "srm_recorder_value"
			},
			2: {
				"name": "SRM B - D",
				"color": Color(0, 0, 1),
				"unit": "CPS",
				"value_source": "func",
				"func": "srm_recorder_value"
			},
		},
	},
	"irm_aprm_a_c_chart_recorder": {
		"values": {
			1: {
				"name": "IRM A - APRM A",
				"color": Color(1, 0, 0),
				"unit": "%",
				"value_source": "func",
				"func": "irm_aprm_rbm_recorder_value"
			},
			2: {
				"name": "IRM C - APRM C",
				"color": Color(0, 0, 1),
				"unit": "%",
				"value_source": "func",
				"func": "irm_aprm_rbm_recorder_value"
			},
		},
	},
	"irm_aprm_b_d_chart_recorder": {
		"values": {
			1: {
				"name": "IRM B - APRM B",
				"color": Color(1, 0, 0),
				"unit": "%",
				"value_source": "func",
				"func": "irm_aprm_rbm_recorder_value"
			},
			2: {
				"name": "IRM D - APRM D",
				"color": Color(0, 0, 1),
				"unit": "%",
				"value_source": "func",
				"func": "irm_aprm_rbm_recorder_value"
			},
		},
	},
	"irm_aprm_rbm_e_g_a_chart_recorder": {
		"values": {
			1: {
				"name": "IRM E - APRM E",
				"color": Color(1, 0, 0),
				"unit": "%",
				"value_source": "func",
				"func": "irm_aprm_rbm_recorder_value"
			},
			2: {
				"name": "IRM G - RBM A",
				"color": Color(0, 0, 1),
				"unit": "%",
				"value_source": "func",
				"func": "irm_aprm_rbm_recorder_value"
			},
		},
	},
	"irm_aprm_rbm_f_h_b_chart_recorder": {
		"values": {
			1: {
				"name": "IRM F - APRM F",
				"color": Color(1, 0, 0),
				"unit": "%",
				"value_source": "func",
				"func": "irm_aprm_rbm_recorder_value"
			},
			2: {
				"name": "IRM H - RBM B",
				"color": Color(0, 0, 1),
				"unit": "%",
				"value_source": "func",
				"func": "irm_aprm_rbm_recorder_value"
			},
		},
	},
}

var selector_switches = {
	"control_room_emergency_lighting": {
		"func": "control_room_emergency_lighting_switch",
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
	},
	"control_room_normal_lighting": {
		"func": "control_room_normal_lighting_switch",
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false, # TODO: make it possible to specify a specific position to return to
							# and, make it possible to use this on switches with less/more than three positions
	},
	"scram_reset_a": {
		"func": "scram_reset",
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
	},
	"scram_reset_b": {
		"func": "scram_reset",
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
	},
	"scram_reset_c": {
		"func": "scram_reset",
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
	},
	"scram_reset_d": {
		"func": "scram_reset",
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
	},
	"srm_channel_select_a": {
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 2,
		"momentary": false,
	},
	"srm_channel_select_b": {
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
	},
	"irm_aprm_select_a": {
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
	},
	"irm_aprm_select_b": {
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
	},
	"irm_aprm_select_c": {
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
	},
	"irm_aprm_select_d": {
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
	},
	"irm_aprm_select_e": {
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
	},
	"irm_aprm_select_f": {
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
	},
	"irm_rbm_select_g_a": {
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
	},
	"irm_rbm_select_h_b": {
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
	},
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
func _process(_delta):
	#print(Engine.get_frames_per_second())
	pass
	
func trip_rps_a(reason):
	rps["a"]["reasons"][reason] = true
	if rps["a"]["trip_timer"] == -1:
		rps["a"]["trip_timer"] = 120
	if not "A1" in scram_breakers and not "A2" in scram_breakers:
		scram_breakers["A1"] = reason
		scram_breakers["A2"] = reason

func trip_rps_b(reason):
	rps["b"]["reasons"][reason] = true
	if rps["b"]["trip_timer"] == -1:
		rps["b"]["trip_timer"] = 120
	if not "B1" in scram_breakers and not "B2" in scram_breakers:
		scram_breakers["B1"] = reason
		scram_breakers["B2"] = reason

func reset_scram():
	if scram_active and scram_breakers == {} and not rps["b"]["trip"] and not rps["b"]["trip"]:
		scram_all_rods_in = false
		scram_active = false
		scram_breakers = {}
		add_new_block("SCRAM","r_withdraw_block")
		for rod_number in control_rods:
			control_rods[rod_number].cr_scram = false

func main_loop_timer_expire():
	# mode switch shutdown scram logic
	
	if reactor_mode == reactor_modes.SHUTDOWN:
		if mode_switch_shutdown_timer == -1:
			mode_switch_shutdown_timer = 100
			
		if mode_switch_shutdown_timer != 0:
			mode_switch_shutdown_timer -= 1
		
		if not "mode_switch_shutdown" in rps["a"]["bypasses"]:
			trip_rps_a("mode_switch_shutdown")
			
		if mode_switch_shutdown_timer == 0:
			rps["a"]["bypasses"]["mode_switch_shutdown"] = true

		if not "mode_switch_shutdown" in rps["b"]["bypasses"]:
			trip_rps_b("mode_switch_shutdown")
			
		if mode_switch_shutdown_timer == 0:
			rps["b"]["bypasses"]["mode_switch_shutdown"] = true
			
	elif reactor_mode != reactor_modes.SHUTDOWN:
		mode_switch_shutdown_timer = -1
		if "mode_switch_shutdown" in rps["a"]["bypasses"]:
			rps["a"]["bypasses"].erase("mode_switch_shutdown")
			
		if "mode_switch_shutdown" in rps["b"]["bypasses"]:
			rps["b"]["bypasses"].erase("mode_switch_shutdown")
			
	if rps["a"]["trip"]:
		if rps["a"]["trip_timer"] > 0:
			rps["a"]["trip_timer"] -= 1
		if not "A1" in scram_breakers and rps["a"]["trip_timer"] > 0:
			scram_breakers["A1"] = scram_breakers["A2"]
		elif not "A2" in scram_breakers and rps["a"]["trip_timer"] > 0:
			scram_breakers["A2"] = scram_breakers["A1"]
		
	if rps["b"]["trip"]:
		if rps["b"]["trip_timer"] > 0:
			rps["b"]["trip_timer"] -= 1
		if not "B1" in scram_breakers and rps["b"]["trip_timer"] > 0:
			scram_breakers["B1"] = scram_breakers["B2"]
		elif not "B2" in scram_breakers and rps["b"]["trip_timer"] > 0:
			scram_breakers["B2"] = scram_breakers["B1"]
			
	# apply rod withdraw blocks
	if reactor_mode == reactor_modes.SHUTDOWN:
		add_new_block("Mode Switch in Shutdown","withdraw_block")
	else:
		add_new_block("Mode Switch in Shutdown","r_withdraw_block")
		
	var irm_downscale = false
	for irm_number in intermediate_range_monitors:
		if intermediate_range_monitors[irm_number]["adjusted_power"] < 5 and not intermediate_range_monitors[irm_number]["scale"] == 1:
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
		var full_scram = rps["a"]["trip"] and rps["b"]["trip"]
		
		if not rps["a"]["trip"] and rps["a"]["reasons"] != {}:
			rps["a"]["trip"] = true
			
		elif rps["a"]["trip"] and rps["a"]["reasons"] == {}:
			rps["a"]["trip"] = false
			rps["a"]["trip_timer"] = -1
			
		if not rps["b"]["trip"] and rps["b"]["reasons"] != {}:
			rps["b"]["trip"] = true
			
		elif rps["b"]["trip"] and rps["b"]["reasons"] == {}:
			rps["b"]["trip"] = false
			rps["b"]["trip_timer"] = -1
		
		if rps["a"]["trip_timer"] == 0:
			rps["a"]["reset_permit"] = true
			
		if rps["b"]["trip_timer"] == 0:
			rps["b"]["reset_permit"] = true
		
		manual_scram_pb_materials["A1"].emission_enabled = false
		manual_scram_pb_materials["A2"].emission_enabled = false
		manual_scram_pb_materials["B1"].emission_enabled = false
		manual_scram_pb_materials["B2"].emission_enabled = false
		#last_tick_a1 = "A1" in scram_breakers
		#last_tick_a2 = "A2" in scram_breakers
		#last_tick_b1 = "B1" in scram_breakers
		#last_tick_b2 = "B2" in scram_breakers
		
		for breaker in scram_breakers:
			manual_scram_pb_materials[breaker].emission_enabled = true
		
		if full_scram:
			if not scram_active:
				scram(scram_types.MANUAL)
		else:
			scram_all_rods_in = false
			scram_active = false
			add_new_block("SCRAM","r_withdraw_block")
			for rod_number in control_rods:
				control_rods[rod_number].cr_scram = false
			
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

func rod_selector_pressed(_camera, _event, _position, _normal, _shape_idx, parent_object):
	change_selected_rod(parent_object.name)
	
func scram(type):
	scram_type = type
	add_new_block("SCRAM","withdraw_block")
	var rods_in = 0
	var begin_scram_rod_movement = false
	while rods_in < 185:
		rods_in = 0
		for rod_number in control_rods:
			scram_active = true
			var rod_info = control_rods[rod_number]
			var cr_insertion = rod_info["cr_insertion"]
			var cr_accum_trouble = rod_info["cr_accum_trouble"]
			var cr_accum_trouble_acknowledged = rod_info["cr_accum_trouble_acknowledged"]

			#not realistic, fix when accums are added
			cr_accum_trouble = true
			cr_accum_trouble_acknowledged = false
			
			if cr_insertion != 0:
				if begin_scram_rod_movement == true:
					if not rod_number in moving_rods:
						moving_rods.append(rod_number)
					# TODO: insertion time changes with RPV pressure and CRD system/accumulator pressure
					# the time from full out to full in is around ~2.6 seconds
					cr_insertion -= rod_info["cr_scram_insertion_speed"]
					if cr_insertion <= 0:
						cr_insertion = 0
				else:
					await get_tree().create_timer(0.3).timeout
					begin_scram_rod_movement = true
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
	
	# insert for 1.4 seconds each cycle
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
		if parent.name in ["A1","A2"]:
			trip_rps_a(scram_types.MANUAL)
		else:
			trip_rps_b(scram_types.MANUAL)
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
	elif parent.name == "DriftTest_pb":
		cr_drift_test = pressed
	elif parent.name == "DriftReset_pb":
		if pressed == true:
			for rod_number in control_rods:
				control_rods[rod_number]["cr_drift_alarm"] = false
	elif parent.name == "AccumAck_pb":
		for rod_number in control_rods:
			control_rods[rod_number].cr_accum_trouble_acknowledged = true
