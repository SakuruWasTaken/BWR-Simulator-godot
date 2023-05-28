extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_rpis_toggled(button_pressed):
	$"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display/full core display lights".set_rpis_inop(button_pressed)


func _on_rwm_toggled(button_pressed):
	$"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box".set_rwm_inop(true)
	$"Settings Button/Settings Menu/RWM/RWM".disabled = true
