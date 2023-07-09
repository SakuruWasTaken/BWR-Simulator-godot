extends Node3D

@onready var node_3d = $"/root/Node3d"

var sources = {
	"GROUND":
		{
			"type": "AC",
			"voltage": 0,
			"frequency": 0,
			"amperage": 0.00,
			"loads": {},
		},
	"CBTRB":
		{
			"type": "AC",
			"voltage": 4160,
			"frequency": 60,
			"amperage": 0.00,
			"loads": {},
		},
	"N1":
		{
			"type": "AC",
			"voltage": 0,
			"frequency": 0.00,
			"amperage": 0.00,
			"loads": {},
		},
	"N2":
		{
			"type": "AC",
			"voltage": 0,
			"frequency": 0.00,
			"amperage": 0.00,
			"loads": {},
		},
	"S_4160V":
		{
			"type": "AC",
			"voltage": 4160,
			"frequency": 60.00,
			"amperage": 0.00,
			"loads": {},
		},
	"S_6900V":
		{
			"type": "AC",
			"voltage": 6900,
			"frequency": 60.00,
			"amperage": 0.00,
			"loads": {},
		},
	"DG1":
		{
			"type": "AC",
			"voltage": 0,
			"frequency": 0,
			"amperage": 0.00,
			"loads": {},
		},
	"DG2":
		{
			"type": "AC",
			"voltage": 0,
			"frequency": 0,
			"amperage": 0.00,
			"loads": {},
		}
	
}

@onready var busses = {
	"1":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 4160,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
			"indicators": {
				"voltage": {
					"type": "scale",
					"pointer": $"/root/Node3d/Control Room Panels/Main Panel Right Side/Electrical System/SM-1 Section/Indicators/Voltage/Pointer",
					"scale_max": 5000,
				}
			},
		},
	"2":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 4160,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
			"indicators": {
				"voltage": {
					"type": "scale",
					"pointer": $"/root/Node3d/Control Room Panels/Main Panel Right Side/Electrical System/SM-2 Section/Indicators/Voltage/Pointer",
					"scale_max": 5000,
				}
			},
		},
	"3":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 4160,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
			"indicators": {
				"voltage": {
					"type": "scale",
					"pointer": $"/root/Node3d/Control Room Panels/Main Panel Right Side/Electrical System/SM-3 Section/Indicators/Voltage/Pointer",
					"scale_max": 5000,
				}
			},
		},
	"4":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 4160,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"5":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 6100,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"6":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 6100,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"7":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 4160,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
			"indicators": {
				"voltage": {
					"type": "scale",
					"pointer": $/root/Node3d/"Control Room Panels/Main Panel Right Side/Electrical System/SM-7 Section/Indicators/Voltage/Pointer",
					"scale_max": 5000,
				}
			},
		},
	"8":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 4160,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"11":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 480,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"21":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 480,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"31":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 480,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"51":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 480,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"52":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 480,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"53":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 480,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"54":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 480,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"61":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 480,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"62":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 480,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"63":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 480,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"75":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 4160,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
	"85":
		{
			"type": "AC",
			"voltage": 0,
			"normal_voltage": 4160,
			"frequency": 0.00,
			"phase_angle": 0,
			"amperage": 0.00,
			"loads": [],
			"feeders": [],
		},
}

var breakers = {
	#"cb_75_72": 
		#{
			#"input": "75",
			#"output": "72",
			#"closed": false,
			#"lockout": false,
			#"auto_close_inhibit": false,
		#},
	"cb_7DG1": 
		{
			"input": "DG1",
			"output": "cb_DG1_7",
			"closed": false,
			"lockout": false,
			"auto_close_inhibit": false,
		},
	"cb_DG1_7":
		{
			"input": "cb_7DG1",
			"output": "7",
			"closed": false,
			"lockout": false,
			"auto_close_inhibit": false,
		},
	"cb_B7": 
		{
			"input": "CBTRB",
			"output": "7",
			"closed": false,
			"lockout": false,
			"auto_close_inhibit": false,
		},
	"cb_7_75_1": 
		{
			"input": "7",
			"output": "75",
			"closed": false,
			"lockout": false,
			"auto_close_inhibit": false,
		},
	#"cb_7_73":  - 480v, requires transformer implementation!
		#{
			#"input": "7",
			#"output": "73",
			#"closed": false,
			#"lockout": false,
			#"auto_close_inhibit": false,
		#},
	#"cb_7_71": - 480v, requires transformer implementation!
		#{
			#"input": "7",
			#"output": "71",
			#"closed": false,
			#"lockout": false,
		#	"auto_close_inhibit": false,
		#},
	"cb_7_1": 
		{
			"input": "cb_1_7",
			"output": "7",
			"closed": true,
			"lockout": false,
			"auto_close_inhibit": false,
		},
	#all breakers DIRECTLY connected to bus SM-7^^^
	
	#SM-1
	"cb_1_7": 
		{
			"input": "1",
			"output": "cb_7_1",
			"closed": false,
			"lockout": false,
			"auto_close_inhibit": false,
		},
	
	
	"cb_N1_1":
		{
			"input": "N1",
			"output": "1",
			"closed": false,
			"lockout": false,
			"auto_close_inhibit": false,
		},
	"cb_S1":
		{
			"input": "S_4160V",
			"output": "1",
			"closed": true,
			"lockout": false,
			"auto_close_inhibit": false,
		},
	"cb_N1_2":
		{
			"input": "N1",
			"output": "2",
			"closed": false,
			"lockout": false,
			"auto_close_inhibit": false,
		},
	"cb_S2":
		{
			"input": "S_4160V",
			"output": "2",
			"closed": true,
			"lockout": false,
			"auto_close_inhibit": false,
		},
	"cb_N1_3":
		{
			"input": "N1",
			"output": "3",
			"closed": false,
			"lockout": false,
			"auto_close_inhibit": false,
		},
	"cb_S3":
		{
			"input": "S_4160V",
			"output": "3",
			"closed": true,
			"lockout": false,
			"auto_close_inhibit": false,
		},
}

func _ready():
	while node_3d.breaker_switches == null:
		await get_tree().create_timer(0.1).timeout
	while true:
		for bus in busses:
			busses[bus]["feeders"] = []
		for breaker in breakers:
			var breaker_info = breakers[breaker]
			var input_info = null
			var output_info = null
			var input_type = "breaker"
			var output_type = "breaker"
			if breaker_info["input"] in sources: #editing by watchful, attempting to add breaker to breaker connection
				input_info = sources[breaker_info["input"]]
				input_type = "source"
			elif breaker_info["input"] in busses:
				input_info = busses[breaker_info["input"]]
				input_type = "bus"
			else:
				input_info = breakers[breaker_info["input"]]
			if breaker_info["output"] in busses:
				output_info = busses[breaker_info["output"]]
				output_type = "bus"
			else:
				output_info = breakers[breaker_info["output"]]
			
			if  input_type =="source" and input_info["voltage"] == 0:
				breaker_info.closed = false
			elif input_type == "breaker" and input_info["lockout"]:
				breaker_info.closed = false
			elif breaker_info.lockout:
				breaker_info.closed = false
			# set the lights on the corresponding switch for the breaker to reflect the status of the breaker
			if breaker in node_3d.breaker_switches:
				node_3d.breaker_switches[breaker]["light_on"].emission_enabled = breaker_info.closed
				node_3d.breaker_switches[breaker]["light_off"].emission_enabled = !breaker_info.closed
				if node_3d.breaker_switches[breaker]["light_lockout"] != null:
					node_3d.breaker_switches[breaker]["light_lockout"].emission_enabled = !breaker_info.lockout	
			
			if breaker_info.closed and output_type == "bus": 
				output_info["feeders"].append(breaker)
		
		for source in sources:
			sources[source]["loads"] = {}
			sources[source]["amperage"] = 0.00
		
		for bus in busses:
			var bus_info = busses[bus]
			if len(bus_info["feeders"]) > 0:
				for feeder in bus_info["feeders"]: #in case of two breakers being linked, che
					var source_info = null
					if feeder in breakers:
						if breakers[feeder]["input"] in sources:
							source_info = sources[breakers[feeder]["input"]]
						else:
							if breakers[breakers[feeder]["input"]]["closed"] == true:
								source_info = busses[breakers[breakers[feeder]["input"]]["input"]]

							else:
								source_info = sources["GROUND"]
					else:
						source_info = sources[breakers[feeder]["input"]]

					
					# TODO: calculate load
					
					# TODO: calculate load between multiple feeders on a single bus
					# (if a single bus has multiple connected feeders)
					
					bus_info["voltage"] = source_info["voltage"]
					bus_info["frequency"] = source_info["frequency"]
					#source_info["loads"][feeder] = 0.00 useless for now
			else:
				bus_info["voltage"] = 0
				bus_info["frequency"] = 0.00
				
		for bus in busses:
			var bus_info = busses[bus]
			if "indicators" in bus_info:
				for indicator in bus_info["indicators"]:
					var indicator_info = bus_info["indicators"][indicator]
					if indicator_info["type"] == "scale":
						indicator_info["pointer"].position.z = node_3d.calculate_vertical_scale_position(bus_info[indicator], indicator_info["scale_max"])
		
			
		await get_tree().create_timer(0.1).timeout
