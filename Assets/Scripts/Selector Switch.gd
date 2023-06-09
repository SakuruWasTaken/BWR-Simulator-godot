extends StaticBody3D

func control_room_emergency_lighting_switch(position):
	var lights_on = position in [1, 2]
	var on_light_material = $"../Lights/On/CSGSphere3D".get_material()
	var off_light_material = $"../Lights/Off/CSGSphere3D".get_material()
	
	for node in $"/root/Node3d/Control Room Lights/emergency".get_children():
		node.light_energy = 0.3 if lights_on else 0
		for child_node in node.get_children():
			child_node.get_material().emission_enabled = lights_on
	on_light_material.emission_enabled = lights_on
	off_light_material.emission_enabled = !lights_on

func control_room_normal_lighting_switch(position):
	var lights_on = position in [1, 2]
	var on_light_material = $"../Lights/On/CSGSphere3D".get_material()
	var off_light_material = $"../Lights/Off/CSGSphere3D".get_material()
	for node in $"/root/Node3d/Control Room Lights/normal".get_children():
		node.light_energy = 0.712 if lights_on else 0
		for child_node in node.get_children():
			if child_node is CSGBox3D:
				child_node.get_material().emission_enabled = lights_on
			elif child_node is SpotLight3D:
				child_node.light_energy = 2.368 if lights_on else 0
	on_light_material.emission_enabled = lights_on
	off_light_material.emission_enabled = !lights_on

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
		"momentary": false,
	},
}
@onready var pointer = $"/root/Node3d/Control Room Panels/Main Panel Center/Controls/Momentary Switch/EDG 14 KV/Pointer"
@onready var node_3d = $"/root/Node3d"
#@onready var on_light_material = $"../Lights/On/CSGSphere3D".get_material() if "Momentary" not in get_parent().name else ""
#@onready var off_light_material = $"../Lights/Off/CSGSphere3D".get_material() if "Momentary" not in get_parent().name else ""
var value = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	#if "Momentary" in get_parent().name:
	#	while true:
	#		await get_tree().create_timer(0.05).timeout
	#		if switch_position == 2:
	#			value += 0.1
	#		elif switch_position == 0:
	#			value -= 0.1
	#			
	#		pointer.position.z = node_3d.calculate_vertical_scale_position(value, 5, 0.071, -0.071)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func breaker_switch_position_up(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var name = get_parent().name
		if mouse_click.pressed:
			if not switches[name]["position"] == 2:
				switches[name]["position"] += 1
				$"../AudioStreamPlayer3D".playing = true
				$"../Handle".set_rotation_degrees(Vector3(switches[name]["positions"][switches[name]["position"]], 0, 0))
				call(switches[name]["func"], switches[name]["position"])
		elif switches[name]["position"] == 2 and "Momentary" in get_parent().name:
			switches[name]["position"] = 1
			$"../AudioStreamPlayer3D".playing = true
			$"../Handle".set_rotation_degrees(Vector3(switches[name]["positions"][switches[name]["position"]], 0, 0))
			if "func" in switches[name]:
				call(switches[name]["func"], switches[name]["position"])
					

func breaker_switch_position_down(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var name = get_parent().name
		if mouse_click.pressed:
			if not switches[name]["position"] == 0:
				switches[name]["position"] -= 1
				$"../AudioStreamPlayer3D".playing = true
				$"../Handle".set_rotation_degrees(Vector3(switches[name]["positions"][switches[name]["position"]], 0, 0))
				call(switches[name]["func"], switches[name]["position"])
		elif switches[name]["position"] == 0 and switches[name]["momentary"]:
			switches[name]["position"] = 1
			$"../AudioStreamPlayer3D".playing = true
			$"../Handle".set_rotation_degrees(Vector3(switches[name]["positions"][switches[name]["position"]], 0, 0))
			if "func" in switches[name]:
				call(switches[name]["func"], switches[name]["position"])

