extends Node2D

@onready var node_3d = $"/root/Node3d"

var recorder_name
var value_page

func srm_recorder_value(value_name):
	var values_to_get = {
		"SRM A - C": {
			0: "A",
			1: null,
			2: "C",
		},
		"SRM B - D": {
			0: "B",
			1: null,
			2: "D",
		},
	}
	
	var switch_to_get = "srm_channel_select_a" if value_name == "SRM A - C" else "srm_channel_select_b"
	var value_to_get = values_to_get[value_name][node_3d.selector_switches[switch_to_get].position]
	
	if value_to_get != null:
		return node_3d.source_range_monitors[value_to_get].value
	
	return 0

func irm_aprm_rbm_recorder_value(value_name):
	var detectors_to_get = {
		"IRM A - APRM A": {
			"switch": "irm_aprm_select_a",
			"detector": "A",
		},
		"IRM B - APRM B": {
			"switch": "irm_aprm_select_b",
			"detector": "B",
		},
		"IRM C - APRM C": {
			"switch": "irm_aprm_select_c",
			"detector": "C",
		},
		"IRM D - APRM D": {
			"switch": "irm_aprm_select_d",
			"detector": "D",
		},
		"IRM E - APRM E": {
			"switch": "irm_aprm_select_e",
			"detector": "E",
		},
		"IRM F - APRM F": {
			"switch": "irm_aprm_select_f",
			"detector": "F",
		},
		"IRM G - RBM A": {
			"switch": "irm_rbm_select_g_a",
			"detector": "G",
			"detector_rbm": "A",
		},
		"IRM H - RBM B": {
			"switch": "irm_rbm_select_h_b",
			"detector": "H",
			"detector_rbm": "B",
		},
	}
	
	var detector_to_get = detectors_to_get[value_name]
	var value = 0

	if node_3d.selector_switches[detector_to_get.switch].position == 0:
		value = node_3d.intermediate_range_monitors[detector_to_get.detector].adjusted_power
	elif node_3d.selector_switches[detector_to_get.switch].position == 1 and not "detector_rbm" in detector_to_get:
		value = node_3d.average_power_range_monitors[detector_to_get.detector]
	elif node_3d.selector_switches[detector_to_get.switch].position == 1 and "detector_rbm" in detector_to_get:
		# TODO: add RBM
		value = "TODO"
		
		
	return value

# Called when the node enters the scene tree for the first time.
func _ready():
	recorder_name = get_node("../../../../..").name
	var recorder = node_3d.chart_recorders[recorder_name]
	
	value_page = get_node("Page Values %s" % len(recorder.values))
	value_page.visible = true
	
	for value in recorder.values:
		var value_info = recorder.values[value]
		var value_page_entry = value_page.get_node(str(value))
		
		value_page_entry.get_node("Value Name").text = "%s %s" % [value, value_info.name]
		value_page_entry.get_node("Unit").text = value_info.unit
		
	while true:
		for value in recorder.values:
			var value_info = recorder.values[value]
			var value_page_entry = value_page.get_node(str(value))
			
			var current_value
			
			if value_info.value_source == "value":
				current_value = value_info.value
			elif value_info.value_source == "func":
				current_value = call(value_info.func, value_info.name)
				
			if current_value is float:
				current_value = "%.1f" % current_value
			
			value_page_entry.get_node("Value").text = str(current_value)
			
		await get_tree().create_timer(1).timeout
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
