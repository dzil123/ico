extends Spatial

#onready var grid = $grid2
onready var ico = $rotatesource

# distance between two equilateral triangle centers
# https://en.wikipedia.org/wiki/Equilateral_triangle#Principal_properties
# 2 * radius of inscribed circle
const INV_SQRT_3: float = 1 / sqrt(3)

# https://en.wikipedia.org/wiki/Regular_icosahedron#Dimensions
# radius of a circumscribed sphere
const RADIUS_VERTEX: float = sqrt(10.0 + 2.0 * sqrt(5.0)) / 4.0
# radius of an inscribed sphere
const RADIUS_FACE: float = (sqrt(3.0) * (3.0 + sqrt(5.0))) / 12.0
# midradius
const RADIUS_EDGE: float = (1.0 + sqrt(5.0)) / 4.0
# 180 - dihedral angle
#const ANGLE = PI - acos(sqrt(5.0) / -3.0)  # iso
const ANGLE = PI - acos(1.0 / -3.0)  # octa

var tris = [
	Vector3(1, 0, 0),
	Vector3(1, 1, 0),
	Vector3(0, 1, 0),
	Vector3(0, 1, 1),
	Vector3(0, 0, 1),
	Vector3(1, 0, 1)
]

const TRI_POS_START = Vector3(1, 4, -3)
var tri_pos = TRI_POS_START

var index = 0

# eg a movement of (1,0,0) is rotation by ANGLE on axis rotation_mat3.x
var rotation_mat3 = Basis(
	Vector3(cos(PI / 3.0), 0, -sin(PI / 3.0)),
	Vector3(-1, 0, 0),
	Vector3(cos(PI / 3.0), 0, sin(PI / 3.0))
)


func _ready():
	print("RADIUS_VERTEX: ", RADIUS_VERTEX)
	print("RADIUS_FACE: ", RADIUS_FACE)
	print("RADIUS_EDGE: ", RADIUS_EDGE)
	print("ANGLE: ", ANGLE)

	for tri in tris:
		var pos = Tri.tri_center(tri)
		print(tri, " ", pos)
	do_update()


func do_update():
#	var pos = Tri.tri_center(tris[index % tris.size()])
	var pos = Tri.tri_center(tri_pos)
	$Indicator.translation.x = pos.x
	$Indicator.translation.z = -pos.y  # invert intentionally because godot

	print("points up: ", Tri.points_up(tri_pos))
	print("tri_pos: ", tri_pos)
	print("cart_pos: ", pos)
	ico.translation.x = $Indicator.translation.x
	ico.translation.z = $Indicator.translation.z


func move(delta: Vector3):
	tri_pos += delta
	var rot_axis = rotation_mat3.xform(delta)
	ico.rotate(rot_axis, ANGLE)
	do_update()


func move2(delta: Vector3):
#	move(delta)
	ico.rotate(delta, ANGLE)


func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()

	if event.is_action_pressed("action"):
		index += 1
		do_update()

		ico.rotate(Vector3.LEFT, ANGLE)

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
				ico.transform.basis = Basis()
				tri_pos = TRI_POS_START
				do_update()
