extends Area2D

@onready var monodialog_manager = $MonodialogManager
@onready var monodialog_resource: Monodialog = Monodialog.new()

@export var character_id: String
@export var character_picture: Texture2D
@export var character_name: String
@export var character_voice: AudioStreamMP3
@export var current_branch_index: int = 0
var current_state = "start"
var active_branch_data: Dictionary

@export var start_duration: float = 0.5
@export var hide_duration: float = 0.5
@export var button_sfx: AudioStreamMP3

func _ready() -> void:
	monodialog_resource.read_from_json("res://Scripts/Monodialog/monodialog_data.json")

func start_monodialog():
	var monodialogs = monodialog_resource.get_chara_monodialog(character_id)
	assert(not character_id.is_empty(), "Monodialog: Character ID belum di-setting")
	assert(not monodialogs.is_empty(), "Monodialog: character_id tidak ditemukan")
	print("Entered trigger")
	active_branch_data = monodialogs[current_branch_index]
	if character_name.is_empty():
		character_name = monodialog_resource.get_chara_name(character_id)
	if not character_picture:
		character_picture = load(monodialog_resource.get_chara_picture(character_id))
	if not character_voice:
		character_voice = load(monodialog_resource.get_chara_voice(character_id))
	monodialog_manager.start_monodialog(self)

func get_current_monodialog():
	var monodialogs = monodialog_resource.get_chara_monodialog(character_id)
	if current_branch_index < monodialogs.size():
		for monodialog in monodialogs[current_branch_index]["monodialogs"]:
			if monodialog["state"] == current_state:
				return monodialog
	return null

func set_monodialog_tree(branch_index):
	current_branch_index = branch_index
	current_state = "start"

func set_monodialog_state(state):
	current_state = state

func _on_body_entered(body: Node2D) -> void:
	start_monodialog()
