extends Node

# eg a movement of (1,0,0) is rotation by ANGLE on axis ROTATION_MAT.x
const ROTATION_MAT = Basis(
	Vector3(cos(PI / 3.0), 0, -sin(PI / 3.0)),
	Vector3(-1, 0, 0),
	Vector3(cos(PI / 3.0), 0, sin(PI / 3.0))
)


# tri_dir is one of 6 directions on a triangle grid (cartesian)
func get_rotation_axis(tri_dir: Vector3):
	return ROTATION_MAT.xform(tri_dir)


func apply_rotation(basis: Basis, tri_dir: Vector3):
	return basis.rotated(get_rotation_axis(tri_dir), Octahedron.ANGLE)


func delta_to_move(delta: Vector3) -> int:
	if abs(delta.x) > 0.5:
		return 0
	if abs(delta.y) > 0.5:
		return 1
	if abs(delta.z) > 0.5:
		return 2
	assert(false)
	return 0
