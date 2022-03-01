extends Node

var finger_map := []


func _ready():
	for _i in range(10):
		finger_map.append(null)


func dir_to_action(dir):
	print(dir)
	match dir:
		Vector2.LEFT:
			return "move_left"
		Vector2.RIGHT:
			return "move_right"
		Vector2.UP:
			return "move_up"
		Vector2.DOWN:
			return "move_down"
		_:
			return null


func _input(event):
	if event is InputEventScreenDrag:
		if finger_map[event.index] == null:
			return
		var s = event.speed.snapped(Vector2.ONE * 1000)
		if s != Vector2.ZERO:
			s = s.normalized().snapped(Vector2.ONE)
			var action = dir_to_action(s)
			print(action)
			if action != null:
				print(action, " ", s)
				Input.action_press(action)
				finger_map[event.index] = null

	if event is InputEventScreenTouch:
		if event.pressed:
			finger_map[event.index] = event.position
		else:
			finger_map[event.index] = null
