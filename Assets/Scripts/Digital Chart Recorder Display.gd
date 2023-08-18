extends Node2D

@onready var node_3d = $"/root/Node3d"

var recorder_name
var value_page


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
			
			value_page_entry.get_node("Value").text = str(value_info.value)
			
		await get_tree().create_timer(1).timeout
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
