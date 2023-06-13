extends Node3D

var mode = "Analog"
@onready var display_node = %"full core display lights"
var rpis_inop = false
var previous_selected_rod = "02-19"

# Called when the node enters the scene tree for the first time.
func _ready():
	if mode == "Digital":
		%Analog.visible = false
		%Digital.visible = true
		display_node = %digital_rod_display
	display_node.initalise_rpis()
	
func rod_display_changed(new_rod_display):
	mode = new_rod_display
	if new_rod_display == "Digital":
		previous_selected_rod = $"/root/Node3d".selected_cr
		%Analog.visible = false
		%Digital.visible = true
		display_node = %digital_rod_display
		display_node.initalise_rpis()
	else:
		%Analog.visible = true
		%Digital.visible = false
		display_node = %"full core display lights"
		display_node.initalise_rpis()
		display_node.selected_rod_changed($"/root/Node3d".selected_cr, previous_selected_rod)



func set_rpis_inop(state):
	rpis_inop = state
	display_node.set_rpis_inop(state)
	
func selected_rod_changed(rod_number, previous_selection): display_node.selected_rod_changed(rod_number, previous_selection)
