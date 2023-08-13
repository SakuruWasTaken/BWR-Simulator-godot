extends StaticBody3D
@onready var rwm_box = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box"
var switch_positions = {
	false: 45,
	true: -45
}
func switch_position_up(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
		if not rwm_box.rwm_manual_bypass == true:
			rwm_box.rwm_manual_bypass = true
			$"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Parts/Bypass/AudioStreamPlayer3D".playing = true
			$"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Parts/Bypass/Key".set_rotation_degrees(Vector3(switch_positions[rwm_box.rwm_manual_bypass], 0, -90))
			
func switch_position_down(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
		if not rwm_box.rwm_manual_bypass == false:
			rwm_box.rwm_manual_bypass = false
			$"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Parts/Bypass/AudioStreamPlayer3D".playing = true
			$"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box/Parts/Bypass/Key".set_rotation_degrees(Vector3(switch_positions[rwm_box.rwm_manual_bypass], 0, -90))
