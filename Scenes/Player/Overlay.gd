extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_rpis_toggled(button_pressed):
	$"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display".set_rpis_inop(button_pressed)


func _on_rwm_toggled(button_pressed):
	$"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box".set_rwm_inop(true)
	$"Settings Button/Settings Menu/RWM/RWM".disabled = true


func _on_digital_rod_display_toggled(button_pressed):
	var mode = "Analog"
	if button_pressed == true:
		mode = "Digital"
	$"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display".rod_display_changed(mode)


func _on_rod_display_language_toggled(button_pressed):
	var rpis_language = "EN"
	if button_pressed == true:
		rpis_language = "JP"
	$"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display/Digital/SubViewport/digital_rod_display".rpis_language_changed(rpis_language)
