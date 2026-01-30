extends Node2D

@onready var monodialog_ui = $MonodialogUI

var trigger: Node = null
var reappear = true

func start_monodialog(chara, text = "", options = {}):
	trigger = chara
	if text != "":
		monodialog_ui.show_monodialog(chara.start_duration, chara.character_name, chara.character_picture, text, options, chara.character_voice, false)
	else:
		var monodialog = trigger.get_current_monodialog()
		if not monodialog: return
		monodialog_ui.show_monodialog(chara.start_duration, chara.character_name, chara.character_picture, monodialog["text"], monodialog["options"], chara.character_voice, reappear)
		reappear = true

func stop_monodialog(duration):
	monodialog_ui.hide_monodialog(duration)
	
	var branch_type = "normal"
	if trigger.active_branch_data and trigger.active_branch_data.has("type"):
		branch_type = trigger.active_branch_data["type"]
	
	SignalManager.monodialog_finished.emit(trigger.current_branch_index, branch_type)

func ending(which):
	monodialog_ui.show_ending(which)

func handle_monodialog_choices(option):
	var current_monodialog = trigger.get_current_monodialog()
	if not current_monodialog: return
	var options = current_monodialog.get("options", {})
	var next_state = options.get(option, "start")
	trigger.set_monodialog_state(next_state)
	print("Next state: ", next_state)
	if next_state == "end":
		if trigger.current_branch_index < trigger.monodialog_resource.get_chara_monodialog(trigger.character_id).size() - 1:
			trigger.set_monodialog_tree(trigger.current_branch_index + 1)
		assert(trigger.current_branch_index < trigger.monodialog_resource.get_chara_monodialog(trigger.character_id).size() - 1, "Monodialog: option ending with 'end' but no other branch in monodialog. Check the .json file for errors!")
		stop_monodialog(trigger.hide_duration)
	elif next_state == "exit":
		trigger.set_monodialog_state("start")
		stop_monodialog(trigger.hide_duration)
	elif next_state == "ge":
		ending(1)
	elif next_state == "be":
		ending(2)
	else:
		reappear = false
		start_monodialog(trigger)
