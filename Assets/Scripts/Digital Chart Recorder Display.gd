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
			
			value_page_entry.get_node("Value").text = str(current_value)
			
		await get_tree().create_timer(1).timeout
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
