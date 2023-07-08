extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func cb_85_82_switch(position): print(position) # TODO
func DG2_switch(position): print(position) # TODO
func cb_DG2_8_switch(position): print(position) # TODO
func cb_B8_switch(position): print(position) # TODO
func cb_8DG2_switch(position): print(position) # TODO
func cb_8_85_1_switch(position): print(position) # TODO
func cb_8_83_switch(position): print(position) # TODO
func cb_8_81_switch(position): print(position) # TODO
func cb_8_3_switch(position): print(position) # TODO

@onready var switches = {
	"cb_85_82": {
		"func": "cb_85_82_switch",
		"position": 1,
		"indicator": $"../Indicator".get_material()
	},
	"DG2": {
		"func": "DG2_switch",
		"position": 1,
		"indicator": $"../Indicator".get_material()
	},
	"cb_DG2_8": {
		"func": "cb_DG2_8_switch",
		"position": 1,
		"indicator": $"../Indicator".get_material()
	},
	"cb_B8": {
		"func": "cb_B8_switch",
		"position": 1,
		"indicator": $"../Indicator".get_material()
	},
	"cb_8DG2": {
		"func": "cb_8DG2_switch",
		"position": 1,
		"indicator": $"../Indicator".get_material()
	},
	"cb_8_85_1": {
		"func": "cb_8_85_1_switch",
		"position": 1,
		"indicator": $"../Indicator".get_material()
	},
	"cb_8_83": {
		"func": "cb_8_83_switch",
		"position": 1,
		"indicator": $"../Indicator".get_material()
	},
	"cb_8_81": {
		"func": "cb_8_81_switch",
		"position": 1,
		"indicator": $"../Indicator".get_material()
	},
	"cb_8_3": {
		"func": "cb_8_3_switch",
		"position": 1,
		"indicator": $"../Indicator".get_material()
	},
}

var positions = {
	-1: 90,
	0: 45,
	1: 0,
	2: -45,
}

func breaker_switch_position_up(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var name = get_parent().name
		if name not in switches:
			print("WARNING: a switch with the name '%s' was turned in-game, but this switch was found in the code, the switch will do nothing." % [name])
			return
		if mouse_click.pressed:
			if not switches[name]["position"] in [-1, 0]:
				switches[name]["position"] -= 1
				if switches[name]["position"] == 0:
					switches[name]["indicator"].albedo_color = Color(0, 1, 0)
				$"../AudioStreamPlayer3D".playing = true
				$"../Handle".set_rotation_degrees(Vector3(positions[switches[name]["position"]], 0, 0))
				call(switches[name]["func"], switches[name]["position"])
		elif switches[name]["position"] == 0:
			switches[name]["position"] = 1
			$"../AudioStreamPlayer3D".playing = true
			$"../Handle".set_rotation_degrees(Vector3(positions[switches[name]["position"]], 0, 0))
			if "func" in switches[name]:
				call(switches[name]["func"], switches[name]["position"])

func breaker_switch_position_down(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var name = get_parent().name
		if name not in switches:
			print("WARNING: a switch with the name '%s' was turned in-game, but this switch was found in the code, the switch will do nothing." % [name])
			return
		if mouse_click.pressed:
			if not switches[name]["position"] == 2:
				switches[name]["position"] += 1
				if switches[name]["position"] == 2:
					switches[name]["indicator"].albedo_color = Color(1, 0, 0)
				$"../AudioStreamPlayer3D".playing = true
				$"../Handle".set_rotation_degrees(Vector3(positions[switches[name]["position"]], 0, 0))
				call(switches[name]["func"], switches[name]["position"])
		elif switches[name]["position"] in [2, 0]:
			switches[name]["position"] = 1
			$"../AudioStreamPlayer3D".playing = true
			$"../Handle".set_rotation_degrees(Vector3(positions[switches[name]["position"]], 0, 0))
			if "func" in switches[name]:
				call(switches[name]["func"], switches[name]["position"])

func breaker_switch_position_lock(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var name = get_parent().name
		if name not in switches:
			print("WARNING: a switch with the name '%s' was turned in-game, but this switch was found in the code, the switch will do nothing." % [name])
			return
		if mouse_click.pressed:
			if not switches[name]["position"] == -1:
				switches[name]["indicator"].albedo_color = Color(0, 1, 0)
				switches[name]["position"] = -1
				$"../AudioStreamPlayer3D".playing = true
				$"../Handle".set_rotation_degrees(Vector3(positions[switches[name]["position"]], 0, 0))
				call(switches[name]["func"], switches[name]["position"])
