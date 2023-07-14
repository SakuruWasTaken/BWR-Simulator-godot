extends Node

@onready var electrical = $"/root/Node3d/Control Room Panels/Main Panel Right Side/Electrical System" 
var current_state = true
var new_state = true

func update_lighting(power):
	var lights_on = power
	for node in $"/root/Node3d/Control Room Lights/normal".get_children():
		node.light_energy = 0.712 if lights_on else 0
		for child_node in node.get_children():
			if child_node is CSGBox3D:
				child_node.get_material().emission_enabled = lights_on
			elif child_node is SpotLight3D:
				child_node.light_energy = 2.368 if lights_on else 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	new_state = true if electrical.busses["71"]["voltage"] >= 470 else false
	if current_state != new_state:
		current_state = new_state
		update_lighting(current_state)
	await get_tree().create_timer(0.1).timeout

