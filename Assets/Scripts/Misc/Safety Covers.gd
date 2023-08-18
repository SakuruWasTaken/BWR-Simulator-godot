extends Node3D

var covers = {
	"Insert": {
		"current_position": "normal",
		"normal_position": Vector3(-0.01, 0.185, 0.03),
		"intermediate_position": Vector3(-0.062, 0.185, 0.03),
		"removed_position": Vector3(-0.003, 0.003, -0.141),
		"normal_rotation": Vector3(0, 90, 0),
		"intermediate_rotation": Vector3(0, 90, 0),
		"removed_rotation": Vector3(0, 90, -16.8),
	},
	"Withdraw": {
		"current_position": "normal",
		"normal_position": Vector3(-0.01, 0.185, -0.03),
		"intermediate_position": Vector3(-0.062, 0.185, -0.03),
		"removed_position": Vector3(-0.003, 0.004, -0.204),
		"normal_rotation": Vector3(0, 90, 0),
		"intermediate_rotation": Vector3(0, 90, 0),
		"removed_rotation": Vector3(0, 90, -6.4),
	},
	"Continuous Insert": {
		"current_position": "normal",
		"normal_position": Vector3(-0.01, 0.185, 0.734),
		"intermediate_position": Vector3(-0.062, 0.185, 0.734),
		"removed_position": Vector3(-0.003, 0.012, 0.909),
		"normal_rotation": Vector3(0, 90, 0),
		"intermediate_rotation": Vector3(0, 90, 0),
		"removed_rotation": Vector3(0, 90, -30.3),
	},
	"Continuous Withdraw": {
		"current_position": "normal",
		"normal_position": Vector3(-0.01, 0.185, 0.674),
		"intermediate_position": Vector3(-0.062, 0.185, 0.674),
		"removed_position": Vector3(-0.003, 0.030, 0.839),
		"normal_rotation": Vector3(0, 90, 0),
		"intermediate_rotation": Vector3(0, 90, 0),
		"removed_rotation": Vector3(0, 90, 6.3),
	},
	"Drift Reset": {
		"current_position": "normal",
		"normal_position": Vector3(-0.01, 0.035, 0.674),
		"intermediate_position": Vector3(-0.062, 0.035, 0.674),
		"removed_position": Vector3(-0.01, -0.041, 0.833),
		"normal_rotation": Vector3(0, 90, 0),
		"intermediate_rotation": Vector3(0, 90, 0),
		"removed_rotation": Vector3(0, 90, -13.9),
	},
	"Drift Test": {
		"current_position": "normal",
		"normal_position": Vector3(-0.01, 0.035, 0.733),
		"intermediate_position": Vector3(-0.062, 0.035, 0.733),
		"removed_position": Vector3(-0.01, -0.051, 0.913),
		"normal_rotation": Vector3(0, 90, 0),
		"intermediate_rotation": Vector3(0, 90, 0),
		"removed_rotation": Vector3(0, 90, -1.9),
	},
}


func _on_input_event(camera, event, position, normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
		var cover = covers[get_parent().name]
		var tween = get_tree().create_tween()
		tween.set_parallel()
		if cover.current_position == "normal":
			cover.current_position = "removed"
			tween.tween_property(get_parent(), "position", cover.intermediate_position, 0.2)
			tween.tween_property(get_parent(), "rotation_degrees", cover.intermediate_rotation, 0.2)
			tween.chain().tween_property(get_parent(), "position", cover.removed_position, 0.2)
			tween.tween_property(get_parent(), "rotation_degrees", cover.removed_rotation, 0.2)
		elif cover.current_position == "removed":
			cover.current_position = "normal"
			tween.tween_property(get_parent(), "position", cover.intermediate_position, 0.2)
			tween.tween_property(get_parent(), "rotation_degrees", cover.intermediate_rotation, 0.2)
			tween.chain().tween_property(get_parent(), "position", cover.normal_position, 0.2)
			tween.tween_property(get_parent(), "rotation_degrees", cover.normal_rotation, 0.2)
