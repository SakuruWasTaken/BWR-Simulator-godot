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


@onready var dgs = {
	"dg_1": {
		"state": gen_state.standby,
		"phase": 0,
		"start_time": 0,
		"misc_time": 0,
		"stop_time": 0,
		"open_output_auto": false,
	},
	"dg_2": {
		"state": gen_state.standby,
		"phase": 0,
		"start_time": 0,
		"misc_time": 0,
		"stop_time": 0,
		"close_output_auto": false,
	}
}
#Stop state currently does not function.
func signal_dg(type,dg,state):
	
	print(type)
	
	if type == "VoltLoss":
		if dg==1:
			dgs["dg_1"]["close_output_auto"] = true
		else:
			dgs["dg_2"]["close_output_auto"] = true
	
	
	if dg == 1 and state == "start":
		if dgs["dg_1"]["state"] == gen_state.standby:
			dgs["dg_1"]["state"] = gen_state.starting
			print("dg1starting")
	elif dg == 1 and state == "stop":
		if dgs["dg_1"]["state"] == gen_state.started or dgs["dg_1"]["state"] == gen_state.starting:
			dgs["dg_1"]["state"] = gen_state.stopping
			print("dg1stopping")
	elif dg == 2 and state == "start":
		if dgs["dg_2"]["state"] == gen_state.standby:
			dgs["dg_2"]["state"] = gen_state.starting
			print("dg2starting")
	elif dg == 2 and state == "stop":
		if dgs["dg_2"]["state"] == gen_state.started or dgs["dg_2"]["state"] == gen_state.starting:
			dgs["dg_2"]["state"] = gen_state.stopping
			print("dg2stopping")
	elif dg == 1 and state == "trip":
		if dgs["dg_1"]["state"] == gen_state.started or dgs["dg_1"]["state"] == gen_state.starting:
			dgs["dg_1"]["state"] = gen_state.tripped
			print("Diesel Generator 1 Tripped")
		elif dgs["dg_1"]["state"] == gen_state.standby:
			dgs["dg_1"]["state"] = gen_state.out_of_service
	elif dg == 2 and state == "trip":
		if dgs["dg_2"]["state"] == gen_state.started or dgs["dg_2"]["state"] == gen_state.starting:
			dgs["dg_2"]["state"] = gen_state.tripped
			print("Diesel Generator 2 Tripped")
		elif dgs["dg_2"]["state"] == gen_state.standby:
			dgs["dg_2"]["state"] = gen_state.out_of_service


	
		
# THIS IS NOT READY YET!  and make it come up slowly instead of snapping to 60hz and volt
func _ready():
	while true:
		for gen_name in dgs:
			var gen = dgs[gen_name]
			if gen["state"] == gen_state.starting and gen["start_time"]<120:
				gen["start_time"] += 1
				print(gen["start_time"])
				if gen_name=="dg_1":
					elecsys.breakers["cb_DG1_7"]["closed"] = false
				else:
					elecsys.breakers["cb_DG2_8"]["closed"] = false
			elif gen["state"] == gen_state.starting and gen["start_time"]>=120:
				gen["state"] = gen_state.started
				print("dgstarted")
				gen["start_time"] = 0
				if gen_name=="dg_1":
					elecsys.sources["DG1"]["voltage"] = 4160
					elecsys.sources["DG1"]["frequency"] = 60
					if dgs["dg_1"]["close_output_auto"] == true:
						elecsys.breakers["cb_DG1_7"]["closed"] = true
				elif gen_name=="dg_2":
					elecsys.sources["DG2"]["voltage"] = 4160
					elecsys.sources["DG2"]["frequency"] = 60
					if dgs["dg_2"]["close_output_auto"] == true:
						elecsys.breakers["cb_DG2_8"]["closed"] = true
			if gen["state"] == gen_state.tripped and gen["misc_time"]<60:
				gen["misc_time"] += 1
				gen["start_time"] = 0
				if gen_name=="dg_1":
					elecsys.sources["DG1"]["voltage"] = 0
					elecsys.sources["DG1"]["frequency"] = 0
				elif gen_name=="dg_2":
					elecsys.sources["DG2"]["voltage"] = 0
					elecsys.sources["DG2"]["frequency"] = 0
			elif gen["state"] == gen_state.tripped and gen["misc_time"]>=60:
				gen["misc_time"] = 0
				gen["state"] = gen_state.out_of_service
			if gen["state"] == gen_state.stopping and gen["stop_time"]<60:
				gen["stop_time"] += 1
				if gen_name=="dg_1":
					elecsys.sources["DG1"]["voltage"] = 0
					elecsys.sources["DG1"]["frequency"] = 0
					print("off")
				elif gen_name=="dg_2":
					elecsys.sources["DG2"]["voltage"] = 0
					elecsys.sources["DG2"]["frequency"] = 0
			elif gen["state"] == gen_state.stopping and gen["stop_time"]>=60:
				gen["stop_time"] = 0
				gen["state"] = gen_state.standby
				
				
		await get_tree().create_timer(0.1).timeout
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
