extends Node3D

@onready var node_3d = get_node("/root/Node3d")

# Called when the node enters the scene tree for the first time.
func _ready():
	while true:
		await get_tree().create_timer(0.05).timeout
		for meter_node in self.get_children():
			var pointer = meter_node.get_node("Pointer")
			# TODO: connect these to the completed reactor physics model
			var power = 0
			pointer.position.z = node_3d.calculate_vertical_scale_position(power, 0.071, -0.071, 125)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
