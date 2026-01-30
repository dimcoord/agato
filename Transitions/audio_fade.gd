extends Node

const SILENT_DB := -80.0

func fade_in(
	player: AudioStreamPlayer,
	duration: float = 1.0,
	target_db: float = 0.0
):
	if player == null:
		return

	player.volume_db = SILENT_DB
	player.play()

	var tween := create_tween()
	tween.tween_property(player, "volume_db", target_db, duration)


func fade_out(
	player: AudioStreamPlayer,
	duration: float = 1.0,
	stop_after := true
):
	if player == null:
		return

	var tween := create_tween()
	tween.tween_property(player, "volume_db", SILENT_DB, duration)

	if stop_after:
		tween.finished.connect(player.stop)
