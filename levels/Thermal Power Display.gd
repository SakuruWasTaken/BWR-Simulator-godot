extends CSGBox3D
# Called when the node enters the scene tree for the first time.

var power = 100.00

func _ready():
	while true:
		await get_tree().create_timer(0.1).timeout
		update_power()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
func update_power():
	var decrease_rate = 160
	if power <= 6:
		decrease_rate = 750
		
	print(egg)
		
	power = power-(power/decrease_rate)
	print(power)
	$Power.text = str(int(power))
