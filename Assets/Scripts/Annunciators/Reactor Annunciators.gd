extends Node3D
@onready var node_3d = $"/root/Node3d"

var annunciator_path = "/root/Node3d/Control Room Panels/Main Panel Center/Annunciators/Annunciator Box %s/Node3D/%s"
@onready var alarm_audio = $"/root/Node3d/Control Room Panels/Main Panel Center/Reactor Alarm Loop"
@onready var rwm = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box"
@onready var full_core_display = $"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display/full core display lights"

enum annunciator_state {
	CLEAR, # Annuncuator not lit
	ACTIVE, # Annunciator not acknowledged, flashing quickly
	ACKNOWLEDGED, # Annunciator acknowledged, lit solid
	ACTIVE_CLEAR, # Annunciator condition cleared, but not yet reset by the operator, flashing slowly
}

var cycle = 0
var active_annunciators_lit
var active_clear_annunciators_lit

var testing = false

func check_irm_downscale():
	for irm_number in node_3d.intermidiate_range_monitors:
		if node_3d.intermidiate_range_monitors[irm_number]["adjusted_power"] < 5:
			return true
	return false
func check_aprm_downscale():
	for aprm_number in node_3d.average_power_range_monitors:
		if node_3d.average_power_range_monitors[aprm_number] < 3:
			return true
	return false
func check_rod_out_block(): return node_3d.rod_withdraw_block != []
func check_rwm_rod_block(): return rwm.withdraw_blocks != [] or rwm.insert_blocks != []
func check_rod_drift():
	for rod_number in node_3d.control_rods:
		if node_3d.control_rods[rod_number]["cr_drift_alarm"] == true:
			return true
	return false
func check_cr_accum_trouble():
	for rod_number in node_3d.control_rods:
		if node_3d.control_rods[rod_number]["cr_accum_trouble"] == true:
			return true
	return false
func check_rpis_inop(): return full_core_display.rpis_inop
func check_lprm_downscale():
	for lprm_number in node_3d.local_power_range_monitors:
		for detector in node_3d.local_power_range_monitors[lprm_number]:
			if node_3d.local_power_range_monitors[lprm_number][detector]["power"] < 3:
				return true
	return false
func check_manual_scram_a_trip():
	if "A1" in node_3d.scram_breakers:
		return node_3d.scram_breakers["A1"] in [0, 1]
	elif "A2" in node_3d.scram_breakers:
		return node_3d.scram_breakers["A2"] in [0, 1]
	return false
func check_manual_scram_b_trip():
	if "B1" in node_3d.scram_breakers:
		return node_3d.scram_breakers["B1"] in [0, 1]
	elif "B2" in node_3d.scram_breakers:
		return node_3d.scram_breakers["B2"] in [0, 1]
	return false
func check_auto_scram_a_trip(): return true if "A1" in node_3d.scram_breakers else true if "A2" in node_3d.scram_breakers else false
func check_auto_scram_b_trip(): return true if "B1" in node_3d.scram_breakers else true if "B2" in node_3d.scram_breakers else false
func check_reactor_mode_shutdown_bypass():
	return node_3d.reactor_mode_shutdown_bypass

var annunciators = {
	"irm_downscale": {
		"box": 2,
		"lamp": "A3",
		"material": null,
		"state": annunciator_state.ACKNOWLEDGED,
		"func": "check_irm_downscale"
	},
	"aprm_downscale": {
		"box": 2,
		"lamp": "B3",
		"material": null,
		"state": annunciator_state.ACKNOWLEDGED,
		"func": "check_aprm_downscale"
	},
	"rwm_rod_block": {
		"box": 3,
		"lamp": "A2",
		"material": null,
		"state": annunciator_state.ACKNOWLEDGED,
		"func": "check_rwm_rod_block"
	},
	"rod_out_block": {
		"box": 4,
		"lamp": "B6",
		"material": null,
		"state": annunciator_state.ACKNOWLEDGED,
		"func": "check_rod_out_block"
	},
	"rod_drift": {
		"box": 4,
		"lamp": "C6",
		"material": null,
		"state": annunciator_state.CLEAR,
		"func": "check_rod_drift"
	},
	"rpis_inop": {
		"box": 3,
		"lamp": "D1",
		"material": null,
		"state": annunciator_state.CLEAR,
		"func": "check_rpis_inop"
	},
	"lprm_downscale": {
		"box": 2,
		"lamp": "E2",
		"material": null,
		"state": annunciator_state.ACKNOWLEDGED,
		"func": "check_lprm_downscale"
	},
	"auto_scram_a_trip": {
		"box": 1,
		"lamp": "B2",
		"material": null,
		"state": annunciator_state.CLEAR,
		"func": "check_auto_scram_a_trip"
	},
	"auto_scram_b_trip": {
		"box": 4,
		"lamp": "B2",
		"material": null,
		"state": annunciator_state.CLEAR,
		"func": "check_auto_scram_b_trip"
	},
	"manual_scram_a_trip": {
		"box": 1,
		"lamp": "C2",
		"material": null,
		"state": annunciator_state.CLEAR,
		"func": "check_manual_scram_a_trip"
	},
	# TODO: multiple RPS systems for this trip
	#"reactor_mode_shutdown_bypass": {
	#	"box": 2,
	#	"lamp": "D1",
	#	"material": null,
	#	"state": annunciator_state.ACKNOWLEDGED,
	#	"func": "check_reactor_mode_shutdown_bypass"
	#},
	"manual_scram_b_trip": {
		"box": 4,
		"lamp": "C2",
		"material": null,
		"state": annunciator_state.CLEAR,
		"func": "check_manual_scram_b_trip"
	},
	"cr_accum_trouble": {
		"box": 4,
		"lamp": "A6",
		"material": null,
		"state": annunciator_state.CLEAR,
		"func": "check_cr_accum_trouble"
	},
}

var expression = Expression.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	for annunciator_name in annunciators:
		var annunciator_info = annunciators[annunciator_name]
		annunciators[annunciator_name]["material"] = get_node(annunciator_path % [annunciator_info["box"], annunciator_info["lamp"]]).get_material()
		
		
func control_button_pressed(parent, pressed):
	# TODO: implement test button
	if parent.name == "Ack_pb":
		for annunciator_name in annunciators:
			var condition = call(annunciators[annunciator_name]["func"])
			if condition == false:
				if annunciators[annunciator_name]["state"] == annunciator_state.ACKNOWLEDGED or annunciators[annunciator_name]["state"] == annunciator_state.ACTIVE:
					annunciators[annunciator_name]["state"] = annunciator_state.ACTIVE_CLEAR
			else:	
				if annunciators[annunciator_name]["state"] == annunciator_state.ACTIVE:
					annunciators[annunciator_name]["state"] = annunciator_state.ACKNOWLEDGED
	elif parent.name == "Reset_pb":
		for annunciator_name in annunciators:
			var condition = call(annunciators[annunciator_name]["func"])
			if condition == false:
				annunciators[annunciator_name]["state"] = annunciator_state.CLEAR
	elif parent.name == "Test_pb":
		testing = pressed
			


func _on_timer_timeout():
	active_annunciators_lit = cycle % 2 == 1 
	active_clear_annunciators_lit = cycle/4 % 2 == 1 
	var alarm = false
	for annunciator_name in annunciators:
		var condition = call(annunciators[annunciator_name]["func"]) or testing
		if condition == false:
			if annunciators[annunciator_name]["state"] == annunciator_state.CLEAR:
				annunciators[annunciator_name]["material"].emission_enabled = false
				continue
			elif annunciators[annunciator_name]["state"] == annunciator_state.ACKNOWLEDGED:
				annunciators[annunciator_name]["state"] = annunciator_state.ACTIVE_CLEAR
				
		# there's probably a better way to do this
		if annunciators[annunciator_name]["state"] == annunciator_state.CLEAR:
			annunciators[annunciator_name]["state"] = annunciator_state.ACTIVE
			annunciators[annunciator_name]["material"].emission_enabled = active_annunciators_lit
			alarm = true
		elif annunciators[annunciator_name]["state"] == annunciator_state.ACTIVE:
			annunciators[annunciator_name]["material"].emission_enabled = active_annunciators_lit
			alarm = true
		elif annunciators[annunciator_name]["state"] == annunciator_state.ACTIVE_CLEAR:
			if condition:
				annunciators[annunciator_name]["state"] = annunciator_state.ACTIVE
				annunciators[annunciator_name]["material"].emission_enabled = active_annunciators_lit
				alarm = true
			else:
				annunciators[annunciator_name]["material"].emission_enabled = active_clear_annunciators_lit
		elif annunciators[annunciator_name]["state"] == annunciator_state.ACKNOWLEDGED:
			annunciators[annunciator_name]["material"].emission_enabled = true
			
	if alarm_audio.playing != alarm:
		alarm_audio.playing = alarm
		
	if cycle <= 6:
		cycle += 1
	else: 
		cycle = 0
