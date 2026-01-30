extends Resource

class_name Monodialog

@export var monodialogs = {}

func read_from_json(file_path):
	var data = FileAccess.get_file_as_string(file_path)
	var parsed_data = JSON.parse_string(data)
	if parsed_data:
		monodialogs = parsed_data
	else:
		print("Failed to load/parse: ", parsed_data)

func get_chara_monodialog(chara_id):
	if chara_id in monodialogs:
		return monodialogs[chara_id]["tree"]
	else:
		return []

func get_chara_name(chara_id):
	if chara_id in monodialogs:
		return monodialogs[chara_id]["character_name"]
	else:
		return []

func get_chara_picture(chara_id):
	if chara_id in monodialogs:
		return monodialogs[chara_id]["character_picture"]
	else:
		return []

func get_chara_voice(chara_id):
	if chara_id in monodialogs:
		return monodialogs[chara_id]["character_voice"]
	else:
		return []
