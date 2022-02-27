extends Control

onready var fps_label = $FPS
onready var commit_label = $Commit


func _ready():
	commit_label.text = read_commit().left(7)


func _process(delta):
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var process_fps = 1.0 / max(1e-5, Performance.get_monitor(Performance.TIME_PROCESS))
	fps_label.text = "%.2f\n%.2f" % [fps, process_fps]


func read_commit():
	var content = ""

	var file = File.new()
	var err = file.open("res://commit.txt", File.READ)
	if err:
		push_error("error opening commit.txt: %s" % err)
	else:
		content = file.get_as_text()

	file.close()

	content = content.strip_edges()
	if content == "":
		content = "COMMIT"

	return content
