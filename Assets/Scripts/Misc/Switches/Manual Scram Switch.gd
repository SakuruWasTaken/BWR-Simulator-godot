extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_input_event(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		# TODO: give these buttons a proper sound effect
		#if mouse_click.pressed:
		#	$"/root/Node3d/Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Button Click".playing = true
		#else:
		#	$"/root/Node3d/Control Room Panels/Main Panel Center/Controls/Rod Select Panel/Button Unclick".playing = true
		$"/root/Node3d".rod_motion_button_pressed(get_parent(), mouse_click.pressed)
