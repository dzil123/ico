extends Spatial

export(Vector3) var tri_pos_start = Vector3(1, 4, -3)
export(String) var orientation_start = "R1"

const MOVE_ACTIONS = ["move_up", "move_down", "move_left", "move_right"]

var tri_pos: Vector3
var tri_rot: Basis
var orientation: String

onready var animator = $Animator
onready var map = $Map


func _ready():
	var pos_pointy = Tri.points_up(tri_pos_start)
	var orientation_pointy = Octahedron.POINTY[Octahedron.ORIENTATION_COLOR[orientation_start]]
	assert(pos_pointy == orientation_pointy)
	assert(Tri.is_valid(tri_pos_start))

	reset()
	animator.connect("completed", self, "_on_animator_completed")


func tri_pos_2d() -> Vector2:
	return Tri.tri_center(tri_pos) * Vector2(1, -1)


func tri_pos_3d() -> Vector3:
	var pos = tri_pos_2d()
	return Vector3(pos.x, Octahedron.RADIUS_FACE, pos.y)


func reset():
	animator.cancel()
	tri_pos = tri_pos_start
	orientation = orientation_start
	tri_rot = Octahedron.ROTATIONS[orientation]
	animator.octa.transform = Transform(tri_rot, tri_pos_3d())
	animator.facehud.m_orientation = orientation
	animator.facehud.m_percent_anim = 0
	$MapShader.reset()

	do_update()


func do_update():
	$Indicator.translation = tri_pos_3d() * Vector3(1, 0, 1)

	print(orientation, " ", tri_pos)


func can_move(delta: Vector3) -> bool:
	var new_pos = tri_pos + delta
	return map.in_map(new_pos)


func move(delta: Vector3):
	if not can_move(delta):
		print("invalid")
		return

	var move = Grid.delta_to_move(delta)

	var ani = Ani.new()
	ani.prev_pos = tri_pos_2d()

	tri_pos += delta
	ani.next_pos = tri_pos_2d()
	ani.prev_basis = tri_rot
	ani.rotation_axis = Grid.get_rotation_axis(delta)
	ani.prev_orientation = orientation
	ani.move = move

	orientation = Octahedron.GRAPH[orientation][move]
	tri_rot = Octahedron.ROTATIONS[orientation]

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

	if Input.is_action_just_pressed("reset"):
		reset()

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
