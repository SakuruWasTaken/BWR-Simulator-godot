extends Node2D
@onready var node_3d = $"/root/Node3d"
var insertion = 0
var rpis_language = "EN"
@onready var rwm = $"/root/Node3d/Control Room Panels/Main Panel Center/Meters/RWM Box"
var rpis_inop = false

# called by the parent
func initalise_rpis():
	if $"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display".rpis_inop: return
	rpis_language_changed(rpis_language)
	$"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display/Digital/SubViewport/Background".visible = true
	await get_tree().create_timer(0.3).timeout
	$"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display/Digital/SubViewport/Loading".visible = true
	await get_tree().create_timer(1.3).timeout
	$"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display/Digital/SubViewport/Loading".visible = false
	await get_tree().create_timer(1.5).timeout
	$"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display/Digital/SubViewport/digital_rod_display".visible = true
	$"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display/Digital/SubViewport/Background".visible = false
	while $"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display".mode == "Digital" and not rpis_inop:
		var date = Time.get_date_dict_from_system()
		var time = Time.get_time_dict_from_system()
		$"Time And Date/Time And Date EN".text = "%s/%s/%s %s:%s" % [node_3d.make_string_two_digit(str(date.month)), date.day, str(date.year).right(2), time.hour, time.minute]
		$"Time And Date/Time And Date JP".text = "%s/%s/%s %s:%s" % [str(date.year).right(2), node_3d.make_string_two_digit(str(date.month)), date.day, time.hour, time.minute]
		# TODO: fix and re-enable
		'''
		$"RWM/Group".text = str(rwm.current_group) if rwm.rwm_initalized else ""
		
		if rwm.rwm_initalized:
			var next_rod = ""
			if rwm.current_group_rods != []:
				next_rod = rwm.current_group_rods[0] 
			else:
				break
			var rod_position_from = int(node_3d.control_rods[next_rod]["cr_insertion"]) if not next_rod in node_3d.moving_rods or node_3d.scram_active else node_3d.cr_previous_insertion
			var rod_position_to = rwm.groups["sequence_a"][rwm.current_group]["max_position"]
			$"CR Guide/Selected".text = "SEL    -      →  " if next_rod != node_3d.selected_cr else "SEL  %s  %s→%s" % [next_rod, node_3d.make_string_two_digit(str(rod_position_from)), node_3d.make_string_two_digit(str(rod_position_to))]
			if len(rwm.current_group_rods) > 1 and next_rod == node_3d.selected_cr:
				next_rod = rwm.current_group_rods[1] 
				rod_position_from = int(node_3d.control_rods[next_rod]["cr_insertion"])
			$"CR Guide/Next".text = "NEX    -      →  " if next_rod == node_3d.selected_cr else "NEX  %s  %s→%s" % [next_rod, node_3d.make_string_two_digit(str(rod_position_from)), node_3d.make_string_two_digit(str(rod_position_to))]
		else:
			$"CR Guide/Next".text = "NEX    -      →  "
			$"CR Guide/Selected".text = "SEL    -      →  "
		
		# i know this isn't a great way to do this, but i couldn't find any better way
		$"RWM/Insert Error".text = ""
		for insert_error in rwm.insert_error:
			$"RWM/Insert Error".text = insert_error
			break
			
		$"RWM/Withdraw Error".text = ""
		for withdraw_error in rwm.withdraw_error:
			$"RWM/Withdraw Error".text = withdraw_error
			break
		'''
		
		for rod_number in node_3d.control_rods:
			var rod_info = node_3d.control_rods[rod_number]
			if rod_number in node_3d.moving_rods and not node_3d.scram_active:
				insertion = int(node_3d.cr_previous_insertion)
			else:
				insertion = int(node_3d.control_rods[rod_number]["cr_insertion"])
				
			if insertion == 48:
				insertion = "**"
			else:
				insertion = node_3d.make_string_two_digit(str(insertion))
				
			var label = get_node("Rods/%s" % rod_number)
			label.label_settings.font_color = Color(1, 1, 1) if rod_number == node_3d.selected_cr else Color(1, 0, 1) if rwm.current_group_rods != [] and rod_number == rwm.current_group_rods[0] else Color(0, 1, 1) if rod_number in rwm.current_group_rods else Color(1, 0, 0) if insertion == "**" else Color(0, 1, 0) if insertion == "00" else Color(1, 1, 0)
			label.text = insertion
		await get_tree().create_timer(0.1).timeout
	$"/root/Node3d/Control Room Panels/Main Panel Center/Full Core Display/Digital/SubViewport/digital_rod_display".visible = false

func latched_group_changed(new_group):
	$"RWM/Group".text = str(new_group)

func rpis_language_changed(language):
	rpis_language = language
	
	# this is not a good way of doing localisation,
	# but i don't feel like doing it the proper way in this case,
	# as this is just a quick thing for a few strings
	
	if rpis_language == "JP":
		
		# japan uses YY/MM/DD
		$"Time And Date/Time And Date JP".visible = true
		$"Time And Date/Time And Date EN".visible = false
		
		$"control rod insertion JP".visible = true
		$"control rod insertion EN".visible = false
		$"info/Generator Load/Label JP".visible = true
		$"info/Generator Load/Label EN".visible = false
		$"info/Thermal Power/Label JP".visible = true
		$"info/Thermal Power/Label EN".visible = false
		$"info/Core Flow/Label JP".visible = true
		$"info/Core Flow/Label EN".visible = false
	else:
		$"Time And Date/Time And Date JP".visible = false
		$"Time And Date/Time And Date EN".visible = true
		$"control rod insertion JP".visible = false
		$"control rod insertion EN".visible = true
		$"info/Generator Load/Label JP".visible = false
		$"info/Generator Load/Label EN".visible = true
		$"info/Thermal Power/Label JP".visible = false
		$"info/Thermal Power/Label EN".visible = true
		$"info/Core Flow/Label JP".visible = false
		$"info/Core Flow/Label EN".visible = true
		


func set_rpis_inop(state):
	rpis_inop = state
	if !rpis_inop:
		initalise_rpis()
	

func selected_rod_changed(rod_number, previous_selection):
	pass
