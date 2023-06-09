extends Label3D
@onready var node_3d = $"/root/Node3d"

@onready var time_text = %"Time Text"

func _on_timer_timeout():
	var time_dict = Time.get_time_dict_from_system()
	time_text.text = "%s   %s    %s" % [
										node_3d.make_string_two_digit(str(time_dict.hour)), 
										node_3d.make_string_two_digit(str(time_dict.minute)), 
										node_3d.make_string_two_digit(str(time_dict.second))
										]
