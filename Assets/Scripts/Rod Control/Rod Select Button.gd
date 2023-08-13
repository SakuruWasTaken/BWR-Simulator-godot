extends StaticBody3D


func _on_input_event(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
		$"/root/Node3d/Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Button Click".playing = true
		$"/root/Node3d".rod_selector_pressed(camera, event, position, normal, shape_idx, get_parent())
