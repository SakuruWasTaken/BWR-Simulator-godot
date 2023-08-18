extends StaticBody3D

var switch_positions = {
	0: 45,
	1: 0,
	2: -45,
	3: -90,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func mode_switch_position_up(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
		if not $"/root/Node3d".reactor_mode == 3:
			$"/root/Node3d".reactor_mode += 1
			$"/root/Node3d/Control Room Panels/Main Panel Center/Controls/Reactor Mode Switch/AudioStreamPlayer3D".playing = true
			$"/root/Node3d/Control Room Panels/Main Panel Center/Controls/Reactor Mode Switch/Handle".set_rotation_degrees(Vector3(switch_positions[$"/root/Node3d".reactor_mode], 0, 0))
		

func mode_switch_position_down(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
		if not $"/root/Node3d".reactor_mode == 0:
			$"/root/Node3d".reactor_mode -= 1
			$"/root/Node3d/Control Room Panels/Main Panel Center/Controls/Reactor Mode Switch/AudioStreamPlayer3D".playing = true
			$"/root/Node3d/Control Room Panels/Main Panel Center/Controls/Reactor Mode Switch/Handle".set_rotation_degrees(Vector3(switch_positions[$"/root/Node3d".reactor_mode], 0, 0))

