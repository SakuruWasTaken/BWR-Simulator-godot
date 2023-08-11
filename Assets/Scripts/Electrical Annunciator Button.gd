extends StaticBody3D

func _on_input_event(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
		$"../../Button Click".playing = true
		$"/root/Node3d/Control Room Panels/Main Panel Right Side/Electrical System/Annunciators".control_button_pressed(get_parent())
