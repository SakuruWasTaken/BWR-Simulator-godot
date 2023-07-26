extends Node3D
@onready var node_3d = $"/root/Node3d"
var annunciator_path = "/root/Node3d/Control Room Panels/Main Panel Right Side/Electrical System/Annunciators/Annunciator Box %s/Node3D/%s"
@onready var alarm_audio = $"/root/Node3d/Control Room Panels/Main Panel Right Side/Electrical System/Electrical Alarm Loop"
@onready var electrical_system = $"/root/Node3d/Control Room Panels/Main Panel Right Side/Electrical System"
enum annunciator_state {
	CLEAR, # Annuncuator not lit
	ACTIVE, # Annunciator not acknowledged, flashing quickly
	ACKNOWLEDGED, # Annunciator acknowledged, lit solid
	ACTIVE_CLEAR, # Annunciator condition cleared, but not yet reset by the operator, flashing slowly
}

var cycle = 0
var active_annunciators_lit
var active_clear_annunciators_lit

func check_dg1_autostart(): return true
	

var annunciators = {
	"dg1_autostart": {
		"box": 1,
		"lamp": "AB2/A2",
		"material": null,
		"state": annunciator_state.CLEAR,
		"autoclear": true
	},
}

var expression = Expression.new()

func set_annunciator_active(annunciator_name, state = annunciator_state.ACTIVE, autoclear = true):
	annunciators[annunciator_name]["state"] = state
	annunciators[annunciator_name]["autoclear"] = autoclear

# Called when the node enters the scene tree for the first time.
func _ready():
	for annunciator_name in annunciators:
		var annunciator_info = annunciators[annunciator_name]
		annunciators[annunciator_name]["material"] = get_node(annunciator_path % [annunciator_info["box"], annunciator_info["lamp"]]).get_material()
		
		
func control_button_pressed(parent):
	# TODO: implement test button
	if parent.name == "Ack_pb":
		for annunciator_name in annunciators:
			if "func" in annunciators[annunciator_name]:
				var condition = call(annunciators[annunciator_name]["func"])
				if condition == false:
					if annunciators[annunciator_name]["state"] == annunciator_state.ACKNOWLEDGED or annunciators[annunciator_name]["state"] == annunciator_state.ACTIVE:
						annunciators[annunciator_name]["state"] = annunciator_state.ACTIVE_CLEAR
				elif annunciators[annunciator_name]["state"] == annunciator_state.ACTIVE:
					annunciators[annunciator_name]["state"] = annunciator_state.ACKNOWLEDGED
			else:
				if annunciators[annunciator_name]["autoclear"]:
					if annunciators[annunciator_name]["state"] == annunciator_state.ACKNOWLEDGED or annunciators[annunciator_name]["state"] == annunciator_state.ACTIVE:
						annunciators[annunciator_name]["state"] = annunciator_state.ACTIVE_CLEAR
				elif annunciators[annunciator_name]["state"] == annunciator_state.ACTIVE:
					annunciators[annunciator_name]["state"] = annunciator_state.ACKNOWLEDGED
	elif parent.name == "Reset_pb":
		for annunciator_name in annunciators:
			if (
				("func" in annunciators[annunciator_name] and call(annunciators[annunciator_name]["func"]) == false)
				or annunciators[annunciator_name]["autoclear"]
			):
				annunciators[annunciator_name]["state"] = annunciator_state.CLEAR
					
				if "autoclear" in annunciators[annunciator_name]:
					annunciators[annunciator_name]["autoclear"] = false

func _on_timer_timeout():
	active_annunciators_lit = cycle % 2 == 1 
	active_clear_annunciators_lit = cycle/4 % 2 == 1 
	var alarm = false
	var condition
	for annunciator_name in annunciators:
		if "func" not in annunciators[annunciator_name]:
			if annunciators[annunciator_name]["autoclear"]:
				condition = false
			else:
				if annunciators[annunciator_name]["state"] == annunciator_state.CLEAR:
					annunciators[annunciator_name]["material"].emission_enabled = false
				elif annunciators[annunciator_name]["state"] == annunciator_state.ACTIVE:
					annunciators[annunciator_name]["material"].emission_enabled = active_annunciators_lit
					alarm = true
				elif annunciators[annunciator_name]["state"] == annunciator_state.ACTIVE_CLEAR:
					annunciators[annunciator_name]["material"].emission_enabled = active_clear_annunciators_lit
				elif annunciators[annunciator_name]["state"] == annunciator_state.ACKNOWLEDGED:
					annunciators[annunciator_name]["material"].emission_enabled = true
				continue
		else:
			condition = call(annunciators[annunciator_name]["func"])
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
