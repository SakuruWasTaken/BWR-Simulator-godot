extends CSGBox3D

#@onready var scene = preload("res://levels/node_3d.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
var color = 0


func blink(tween):
	#var s = scene.instantiate()
	var material = $SCRAM.get_material()

	if color == 0:
		material.backlight_enabled = true
		color = 1
	else: 
		material.backlight_enabled = false
		color = 0

	get_node("SCRAM").set_material(material)
	print("a")
	timer(tween)

func timer(tween):
	tween.tween_callback(blink.bind(tween)).set_delay(0.3)

func _ready():
	var tween = get_tree().create_tween()
	blink(tween)


