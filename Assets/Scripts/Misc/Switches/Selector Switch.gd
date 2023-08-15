extends StaticBody3D

@onready var node3d = $"/root/Node3d"

func control_room_emergency_lighting_switch(position):
	var lights_on = position in [1, 2]
	var on_light_material = $"../Lights/On/CSGSphere3D".get_material()
	var off_light_material = $"../Lights/Off/CSGSphere3D".get_material()
	
	for node in $"/root/Node3d/Control Room Lights/emergency".get_children():
		node.light_energy = 0.3 if lights_on else 0.0
		for child_node in node.get_children():
			child_node.get_material().emission_enabled = lights_on
	on_light_material.emission_enabled = lights_on
	off_light_material.emission_enabled = !lights_on

func control_room_normal_lighting_switch(position):
	var lights_on = position in [1, 2]
	var on_light_material = $"../Lights/On/CSGSphere3D".get_material()
	var off_light_material = $"../Lights/Off/CSGSphere3D".get_material()
	for node in $"/root/Node3d/Control Room Lights/normal".get_children():
		node.light_energy = 0.712 if lights_on else 0.0
		for child_node in node.get_children():
			if child_node is CSGBox3D:
				child_node.get_material().emission_enabled = lights_on
			elif child_node is SpotLight3D:
				child_node.light_energy = 2.368 if lights_on else 0.0
	on_light_material.emission_enabled = lights_on
	off_light_material.emission_enabled = !lights_on

func scram_reset(position, name):
	# TODO: timer for half-scram reset
	var breakers = {
		"scram_reset_a": {
			"main": "A1",
			"secondary": "A2",
		},
		"scram_reset_b": {
			"main": "B2",
			"secondary": "B1",
		},
		"scram_reset_c": {
			"main": "A2",
			"secondary": "A1",
		},
		"scram_reset_d": {
			"main": "B1",
			"secondary": "B2",
		},
	}
	var _full_scram = ("A1" in node3d.scram_breakers or "A2" in node3d.scram_breakers) and ("B1" in node3d.scram_breakers or "B2" in node3d.scram_breakers)
	if position == 0:
		if breakers[name].main in node3d.scram_breakers and node3d.scram_timer < 1:
			node3d.scram_breakers.erase(breakers[name].main)
			node3d.manual_scram_pb_materials[breakers[name].main].emission_enabled = false
			node3d.reset_scram()
	else:
		if breakers[name].secondary in node3d.scram_breakers:
			node3d.scram_breakers[breakers[name].main] = node3d.scram_breakers[breakers[name].secondary]

var switches = {
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
			1: 0,
		},
		"position": 1,
		"momentary": false,
	},
	"scram_reset_b": {
		"func": "scram_reset",
		"positions": {
			0: 45,
			1: 0,
		},
		"position": 1,
		"momentary": false,
	},
	"scram_reset_c": {
		"func": "scram_reset",
		"positions": {
			0: 45,
			1: 0,
		},
		"position": 1,
		"momentary": false,
	},
	"scram_reset_d": {
		"func": "scram_reset",
		"positions": {
			0: 45,
			1: 0,
		},
		"position": 1,
		"momentary": false,
	},
}
@onready var node_3d = $"/root/Node3d"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func breaker_switch_position_up(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var name = get_parent().name
		if mouse_click.pressed:
			if switches[name]["position"] + 1 in switches[name]["positions"]:
				switches[name]["position"] += 1
				$"../AudioStreamPlayer3D".playing = true
				$"../Handle".set_rotation_degrees(Vector3(switches[name]["positions"][switches[name]["position"]], 0, 0))
				call(switches[name]["func"], switches[name]["position"], name)
		elif switches[name]["position"] == 2 and "Momentary" in get_parent().name:
			switches[name]["position"] = 1
			$"../AudioStreamPlayer3D".playing = true
			$"../Handle".set_rotation_degrees(Vector3(switches[name]["positions"][switches[name]["position"]], 0, 0))
			if "func" in switches[name]:
				call(switches[name]["func"], switches[name]["position"], name)
					

func breaker_switch_position_down(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var name = get_parent().name
		if mouse_click.pressed:
			if switches[name]["position"] - 1 in switches[name]["positions"]:
				switches[name]["position"] -= 1
				$"../AudioStreamPlayer3D".playing = true
				$"../Handle".set_rotation_degrees(Vector3(switches[name]["positions"][switches[name]["position"]], 0, 0))
				call(switches[name]["func"], switches[name]["position"], name)
		elif switches[name]["position"] == 0 and switches[name]["momentary"]:
			switches[name]["position"] = 1
			$"../AudioStreamPlayer3D".playing = true
			$"../Handle".set_rotation_degrees(Vector3(switches[name]["positions"][switches[name]["position"]], 0, 0))
			if "func" in switches[name]:
				call(switches[name]["func"], switches[name]["position"], name)

