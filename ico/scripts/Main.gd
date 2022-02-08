extends Spatial

# eg a movement of (1,0,0) is rotation by ANGLE on axis rotation_mat3.x
const rotation_mat3 = Basis(
	Vector3(cos(PI / 3.0), 0, -sin(PI / 3.0)),
	Vector3(-1, 0, 0),
	Vector3(cos(PI / 3.0), 0, sin(PI / 3.0))
)
const TRI_POS_START = Vector3(1, 4, -3)

var tri_pos: Vector3
var tri_rot: Basis

onready var animator = $Animator
onready var octa = $octa


func _ready():
	reset()
	animator.connect("completed", self, "_on_animator_completed")


func tri_pos_2d() -> Vector2:
	return Tri.tri_center(tri_pos) * Vector2(1.0, -1.0)


func tri_pos_3d() -> Vector3:
	var pos = tri_pos_2d()
	return Vector3(pos.x, animator.config.RADIUS_FACE, pos.y)


func reset():
	animator.cancel()
	tri_pos = TRI_POS_START
	tri_rot = animator.config.START_ROTATION
	octa.transform = Transform(tri_rot, tri_pos_3d())

	print(octa.transform.basis.get_euler())
	do_update()


func do_update():
#	var pos = Tri.tri_center(tris[index % tris.size()])
	$Indicator.translation = tri_pos_3d() * Vector3(1, 0, 1)

	print("points up: ", Tri.points_up(tri_pos))
	print("tri_pos: ", tri_pos)
	print("cart_pos: ", tri_pos_3d())


func move(delta: Vector3):
	var ani = Ani.new()
	ani.prev_pos = tri_pos_2d()

	tri_pos += delta
	ani.next_pos = tri_pos_2d()
	ani.prev_basis = tri_rot
	ani.rotation_axis = rotation_mat3.xform(delta)

	tri_rot = tri_rot.rotated(ani.rotation_axis, animator.config.ANGLE)

	animator.start(ani)
	do_update()


func move2(delta: Vector3):
	pass


func _on_animator_completed():
	print("animator completed")


func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()

	if event.is_action_pressed("action"):
		$Camera2.current = not $Camera2.current

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