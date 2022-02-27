extends Spatial

const TRI_POS_START = Vector3(1, 4, -3)
const MOVE_ACTIONS = ["move_up", "move_down", "move_left", "move_right"]

var tri_pos: Vector3
var tri_rot: Basis
var orientation

onready var animator = $Animator
onready var octa = $Octa


func _ready():
	reset()
	animator.connect("completed", self, "_on_animator_completed")


func tri_pos_2d() -> Vector2:
	return Tri.tri_center(tri_pos) * Vector2(1.0, -1.0)


func tri_pos_3d() -> Vector3:
	var pos = tri_pos_2d()
	return Vector3(pos.x, Octahedron.RADIUS_FACE, pos.y)


func reset():
	animator.cancel()
	tri_pos = TRI_POS_START
	tri_rot = Octahedron.START_ROTATION
	orientation = Octahedron.START_ORIENTATION
	octa.transform = Transform(tri_rot, tri_pos_3d())

	do_update()


func do_update():
#	var pos = Tri.tri_center(tris[index % tris.size()])
	$Indicator.translation = tri_pos_3d() * Vector3(1, 0, 1)

	print(orientation, " ", tri_pos)


func move(delta: Vector3):
	var ani = Ani.new()
	ani.prev_pos = tri_pos_2d()

	tri_pos += delta
	ani.next_pos = tri_pos_2d()
	ani.prev_basis = tri_rot
	ani.rotation_axis = Grid.get_rotation_axis(delta)

	tri_rot = Grid.apply_rotation(tri_rot, delta)

	var move = Grid.delta_to_move(delta)
	orientation = Octahedron.GRAPH[orientation][move]

	animator.start(ani)
	do_update()


func _on_animator_completed():
	pass


func get_move_dir(action):
	var points_up = Tri.points_up(tri_pos)

	match action:
		"move_left":
			if points_up:
				return Vector3(-1, 0, 0)
			else:
				return Vector3(0, 0, 1)
		"move_right":
			if points_up:
				return Vector3(0, 0, -1)
			else:
				return Vector3(1, 0, 0)
		"move_up":
			if points_up:
				return null
			else:
				return Vector3(0, 1, 0)
		"move_down":
			if points_up:
				return Vector3(0, -1, 0)
			else:
				return null

	push_error("invalid action: " + action)


func _process(_delta):
	if Input.is_action_just_pressed("exit") and not OS.has_feature("web"):
		get_tree().quit()

	if Input.is_action_just_pressed("action"):
		$Camera2.current = not $Camera2.current
		print("pos ", octa.translation)
		print("rot ", octa.transform.basis.get_euler() * 180.0 / PI)

	if not animator.is_moving:
		for action in MOVE_ACTIONS:
			var analog_action = action + "_analog"
			if Input.is_action_pressed(analog_action):
				print("analog action: ", action)
				Input.action_press(action)

	for action in MOVE_ACTIONS:
		if Input.is_action_just_pressed(action):
			var dir = get_move_dir(action)
			if dir != null:
				move(dir)
				break
