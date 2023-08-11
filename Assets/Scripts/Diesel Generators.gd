extends Node3D

@onready var elecsys = $"/root/Node3d/Control Room Panels/Main Panel Right Side/Electrical System"

enum gen_state {
	standby,
	started,
	starting,
	stopping,
	tripped,
	out_of_service
}


var dgs = {
	"dg_1": {
		"state": gen_state.standby,
		"phase": 0,
		"start_time": 0,
		"misc_time": 0,
		"stop_time": 0,
		"close_output_auto": false,
		"output_breaker": "cb_DG1_7",
		"bus": "7",
		"autostart_inhibit": false,
	},
	"dg_2": {
		"state": gen_state.standby,
		"phase": 0,
		"start_time": 0,
		"misc_time": 0,
		"stop_time": 0,
		"close_output_auto": false,
		"output_breaker": "cb_DG2_8",
		"bus": "8",
		"autostart_inhibit": false,
	}
}

func signal_dg(type,dg_name,state):
	dgs[dg_name]["close_output_auto"] = true if type == "VoltLoss" else false
	
	var dg_running = dgs[dg_name]["state"] in [gen_state.started, gen_state.starting]
	
	if state == "start":
		if dgs[dg_name]["state"] == gen_state.standby and not (dgs[dg_name]["autostart_inhibit"] and type != "LOCA"):
			dgs[dg_name]["state"] = gen_state.starting
			get_node("/root/Node3d/Generators/%s" % dg_name).dg_start()
			print("%s starting" % dg_name)
	elif state == "stop" and dg_running:
		dgs[dg_name]["state"] = gen_state.stopping
		get_node("/root/Node3d/Generators/%s" % dg_name).dg_stop()
		print("%s stopping" % dg_name)
	elif state == "trip":
		if dg_running:
			dgs[dg_name]["state"] = gen_state.tripped
			get_node("/root/Node3d/Generators/%s" % dg_name).dg_stop()
			print("%s tripped" % dg_name)
		# TODO: is this realistic?
		#elif dgs[dg_name]["state"] == gen_state.standby:
			#dgs[dg_name]["state"] = gen_state.out_of_service

# THIS IS NOT READY YET!  and make it come up slowly instead of snapping to 60hz and volt
func _ready():
	while true:
		for gen_name in dgs:
			var gen = dgs[gen_name]
			if gen["state"] == gen_state.starting and gen["start_time"]<120:
				gen["start_time"] += 1
				print(gen["start_time"])
				elecsys.breakers[gen["output_breaker"]]["closed"] = false
				
			elif gen["state"] == gen_state.starting and gen["start_time"]>=120:
				gen["state"] = gen_state.started
				print("dgstarted")
				gen["start_time"] = 0
				elecsys.sources[gen_name]["voltage"] = 4160
				elecsys.sources[gen_name]["frequency"] = 60
				if elecsys.busses[gen["bus"]]["voltage"] == 0:
					elecsys.breakers[gen["output_breaker"]]["closed"] = true
					
			if gen["state"] == gen_state.tripped and gen["misc_time"]<60:
				gen["misc_time"] += 1
				gen["start_time"] = 0
				elecsys.sources[gen_name]["voltage"] = 0
				elecsys.sources[gen_name]["frequency"] = 0
					
			elif gen["state"] == gen_state.tripped and gen["misc_time"]>=60:
				gen["misc_time"] = 0
				gen["state"] = gen_state.out_of_service
				
			if gen["state"] == gen_state.stopping and gen["stop_time"]<60:
				gen["stop_time"] += 1
				elecsys.sources[gen_name]["voltage"] = 0
				elecsys.sources[gen_name]["frequency"] = 0
					
			elif gen["state"] == gen_state.stopping and gen["stop_time"]>=60:
				gen["stop_time"] = 0
				gen["state"] = gen_state.standby
				
				
		await get_tree().create_timer(0.1).timeout
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
