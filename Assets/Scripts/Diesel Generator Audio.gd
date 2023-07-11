extends Node3D

func dg_start():
	$"Start".playing = true
	
func _on_start_finished():
	$"Running".playing = true
	
func dg_stop():
	$"Running".playing = false
	$"Start".playing = false
	$"Stop".playing = true
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

