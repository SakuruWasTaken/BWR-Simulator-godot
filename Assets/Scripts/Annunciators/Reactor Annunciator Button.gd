extends StaticBody3D

func _on_input_event(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		$"../../Button Click".playing = true
		if mouse_click.pressed:
			$"/root/Node3d/Control Room Panels/Main Panel Center/Annunciators".control_button_pressed(get_parent(), true)
		elif get_parent().name == "Test_pb":
			$"/root/Node3d/Control Room Panels/Main Panel Center/Annunciators".control_button_pressed(get_parent(), mouse_click.pressed)
