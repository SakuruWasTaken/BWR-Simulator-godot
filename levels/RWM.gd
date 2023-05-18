extends CSGBox3D


# Called when the node enters the scene tree for the first time.
func _ready():
	while true:
		await get_tree().create_timer(0.1).timeout
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
