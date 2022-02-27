extends Spatial

const TRI_POS_START = Vector3(1, 4, -3)

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


func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()

	if event.is_action_pressed("action"):
		$Camera2.current = not $Camera2.current
		print("pos ", octa.translation)
		print("rot ", octa.transform.basis.get_euler() * 180.0 / PI)

	if event.is_action_pressed("move_left"):
		if Tri.points_up(tri_pos):
			move(Vector3(-1, 0, 0))
		else:
			move(Vector3(0, 0, 1))
	if event.is_action_pressed("move_right"):
		if Tri.points_up(tri_pos):
			move(Vector3(0, 0, -1))
		else:
			move(Vector3(1, 0, 0))
	if event.is_action_pressed("move_up"):
		if Tri.points_up(tri_pos):
			pass
		else:
			move(Vector3(0, 1, 0))
	if event.is_action_pressed("move_down"):
		if Tri.points_up(tri_pos):
			move(Vector3(0, -1, 0))
		else:
			pass

	if event is InputEventKey:
		if not event.pressed:
			return
		match event.scancode:
			KEY_R:
				move2(Vector3(cos(PI / 3.0), 0, sin(PI / 3.0)))
			KEY_T:
				move2(Vector3(-cos(PI / 3.0), 0, -sin(PI / 3.0)))
			KEY_F:
				move2(Vector3(cos(PI / 3.0), 0, -sin(PI / 3.0)))
			KEY_G:
				move2(Vector3(-cos(PI / 3.0), 0, sin(PI / 3.0)))
			KEY_V:
				move2(Vector3(-1, 0, 0))
			KEY_B:
				move2(Vector3(1, 0, 0))
			KEY_U:
				reset()
