extends Label3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# this is the first GDScript i've ever written please cut it some slack
	var time_dict = Time.get_time_dict_from_system();
	var hour = str(time_dict.hour)
	var minute = str(time_dict.minute)
	var second = str(time_dict.second)
	
	if len(hour) == 1:
		hour = "0%s" % hour
	
	if len(minute) == 1:
		minute = "0%s" % minute
		
	if len(second) == 1:
		second = "0%s" % second
	
	%"Time Text".text = "%s   %s    %s" % [hour, minute, second]
	pass
