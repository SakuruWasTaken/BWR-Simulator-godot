extends Node3D

@onready var node_3d = $"/root/Node3d"

# Called when the node enters the scene tree for the first time.
func _ready():
	while true:
		for meter_node in self.get_children():
			var period = node_3d.source_range_monitors[meter_node.name].period
			var pointer = meter_node.get_node("Pointer")
			var new_position = 0.059
			if period < 0:
				new_position = node_3d.calculate_vertical_scale_position((period*-1)-100, 400, 0.072, 0.059)
			elif period <= 12:
				new_position = node_3d.calculate_vertical_scale_position(period-10, 2, -0.072, -0.054)
			elif period <= 15:
				new_position = node_3d.calculate_vertical_scale_position(period-12, 3, -0.054, -0.035)
			elif period <= 20:
				new_position = node_3d.calculate_vertical_scale_position(period-15, 5, -0.035, -0.012)
			elif period <= 30:
				new_position = node_3d.calculate_vertical_scale_position(period-20, 10, -0.012, 0.012)
			elif period <= 50:
				new_position = node_3d.calculate_vertical_scale_position(period-30, 20, 0.012, 0.033)
			elif period < 100:
				new_position = node_3d.calculate_vertical_scale_position(period-50, 50, 0.033, 0.046)
			elif period >= 100:
				new_position = node_3d.calculate_vertical_scale_position(period-100, 400, 0.046, 0.059)
			pointer.position.z = new_position
			
		await get_tree().create_timer(0.05).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
