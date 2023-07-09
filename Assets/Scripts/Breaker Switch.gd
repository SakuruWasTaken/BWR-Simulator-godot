extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
@onready var node_3d = $"/root/Node3d"
@onready var electrical_system = $"/root/Node3d/Control Room Panels/Main Panel Right Side/Electrical System"
@onready var generator = $"/root/Node3d/Generators"

func electrical_breaker_switch(position, switch):
	if position == 1:
		electrical_system.breakers[switch]["auto_close_inhibit"] = false
	elif position == 0:
		electrical_system.breakers[switch]["closed"] = false
		electrical_system.breakers[switch]["auto_close_inhibit"] = false
	elif position == 2:
		if electrical_system.breakers[switch]["lockout"] == false:
			electrical_system.breakers[switch]["closed"] = true
		electrical_system.breakers[switch]["auto_close_inhibit"] = false
	elif position == -1:
		electrical_system.breakers[switch]["closed"] = false
		electrical_system.breakers[switch]["auto_close_inhibit"] = true
		
func generator_switch1(position, switch):
	if position == 0:
		generator.signal_dg("Manual",1,"stop")
	elif position == 2:
		generator.signal_dg("Manual",1,"start")
	elif position == -1:
		generator.signal_dg("Manual",1,"trip")
func generator_switch2(position, switch):
	if position == 0:
		generator.signal_dg("Manual",2,"stop")
	elif position == 2:
		generator.signal_dg("Manual",2,"start")
	elif position == -1:
		generator.signal_dg("Manual",2,"trip")

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
		if name not in node_3d.breaker_switches:
			print("WARNING: a switch with the name '%s' was turned in-game, but this switch was found in the code, the switch will do nothing." % [name])
			return
		if mouse_click.pressed:
			if not node_3d.breaker_switches[name]["position"] in [-1, 0]:
				node_3d.breaker_switches[name]["position"] -= 1
				if node_3d.breaker_switches[name]["position"] == 0:
					node_3d.breaker_switches[name]["indicator"].albedo_color = Color(0, 1, 0)
				$"../AudioStreamPlayer3D".playing = true
				$"../Handle".set_rotation_degrees(Vector3(positions[node_3d.breaker_switches[name]["position"]], 0, 0))
				call(node_3d.breaker_switches[name]["func"], node_3d.breaker_switches[name]["position"], name)
		elif node_3d.breaker_switches[name]["position"] == 0:
			node_3d.breaker_switches[name]["position"] = 1
			$"../AudioStreamPlayer3D".playing = true
			$"../Handle".set_rotation_degrees(Vector3(positions[node_3d.breaker_switches[name]["position"]], 0, 0))
			if "func" in node_3d.breaker_switches[name]:
				call(node_3d.breaker_switches[name]["func"], node_3d.breaker_switches[name]["position"], name)

func breaker_switch_position_down(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var name = get_parent().name
		if name not in node_3d.breaker_switches:
			print("WARNING: a switch with the name '%s' was turned in-game, but this switch was found in the code, the switch will do nothing." % [name])
			return
		if mouse_click.pressed:
			if not node_3d.breaker_switches[name]["position"] == 2:
				node_3d.breaker_switches[name]["position"] += 1
				if node_3d.breaker_switches[name]["position"] == 2:
					node_3d.breaker_switches[name]["indicator"].albedo_color = Color(1, 0, 0)
				$"../AudioStreamPlayer3D".playing = true
				$"../Handle".set_rotation_degrees(Vector3(positions[node_3d.breaker_switches[name]["position"]], 0, 0))
				call(node_3d.breaker_switches[name]["func"], node_3d.breaker_switches[name]["position"], name)
		elif node_3d.breaker_switches[name]["position"] in [2, 0]:
			node_3d.breaker_switches[name]["position"] = 1
			$"../AudioStreamPlayer3D".playing = true
			$"../Handle".set_rotation_degrees(Vector3(positions[node_3d.breaker_switches[name]["position"]], 0, 0))
			if "func" in node_3d.breaker_switches[name]:
				call(node_3d.breaker_switches[name]["func"], node_3d.breaker_switches[name]["position"], name)

func breaker_switch_position_lock(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var name = get_parent().name
		if name not in node_3d.breaker_switches:
			print("WARNING: a switch with the name '%s' was turned in-game, but this switch was found in the code, the switch will do nothing." % [name])
			return
		if mouse_click.pressed:
			if not node_3d.breaker_switches[name]["position"] == -1:
				node_3d.breaker_switches[name]["indicator"].albedo_color = Color(0, 1, 0)
				node_3d.breaker_switches[name]["position"] = -1
				$"../AudioStreamPlayer3D".playing = true
				$"../Handle".set_rotation_degrees(Vector3(positions[node_3d.breaker_switches[name]["position"]], 0, 0))
				call(node_3d.breaker_switches[name]["func"], node_3d.breaker_switches[name]["position"], name)
