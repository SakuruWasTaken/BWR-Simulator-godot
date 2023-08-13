extends Label3D
@onready var node_3d = $"/root/Node3d"

@onready var time_text = %"Time Text"

func _on_timer_timeout():
	var time_dict = Time.get_time_dict_from_system()
	time_text.text = "%s%s%s" % [
										node_3d.make_string_two_digit(str(time_dict.hour)), 
										":" if time_dict.second % 2 else " ",
										node_3d.make_string_two_digit(str(time_dict.minute))
										]
