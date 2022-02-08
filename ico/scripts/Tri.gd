class_name Tri
extends Object

# Port of https://github.com/BorisTheBrave/grids/blob/main/src/updown_tri.py

# const edge_length: float = 1
const sqrt3: float = sqrt(3)


# Returns the center of a given triangle in cartesian co-ordinates
static func tri_center(tri: Vector3) -> Vector2:
	tri = tri.round()
	return Vector2(
		0.5 * tri.x + -0.5 * tri.z,
		-sqrt3 / 6.0 * tri.x + sqrt3 / 3.0 * tri.y - sqrt3 / 6.0 * tri.z
	)


# Returns true if this is an upwards pointing triangle, otherwise false
static func points_up(tri: Vector3) -> bool:
	tri = tri.round()
	return int(tri.x) + int(tri.y) + int(tri.z) == 2


# Returns the three corners of a given triangle in cartesian co-ordinates
static func tri_corners(tri: Vector3) -> PoolVector3Array:
	if points_up(tri):
		return PoolVector3Array(
			[
				tri_center(tri + Vector3.RIGHT),
				tri_center(tri + Vector3.BACK),
				tri_center(tri + Vector3.UP)
			]
		)
	else:
		return PoolVector3Array(
			[
				tri_center(tri + Vector3.LEFT),
				tri_center(tri + Vector3.FORWARD),
				tri_center(tri + Vector3.DOWN)
			]
		)


# Returns the triangle that contains a given cartesian co-ordinate point
static func pick_tri(pos: Vector2) -> Vector3:
	return Vector3(
		ceil(1.0 * pos.x - sqrt3 / 3.0 * pos.y),
		floor(sqrt3 * 2.0 / 3.0 * pos.y) + 1.0,
		ceil(-1.0 * pos.x - sqrt3 / 3.0 * pos.y)
	)


# Returns the tris that share an edge with the given tri
static func tri_neighbors(tri: Vector3) -> PoolVector3Array:
	if points_up(tri):
		return PoolVector3Array(
			[
				tri_center(tri + Vector3.LEFT),
				tri_center(tri + Vector3.DOWN),
				tri_center(tri + Vector3.FORWARD)
			]
		)
	else:
		return PoolVector3Array(
			[
				tri_center(tri + Vector3.RIGHT),
				tri_center(tri + Vector3.UP),
				tri_center(tri + Vector3.BACK)
			]
		)


# Returns how many steps one tri is from another
static func tri_dist(tri1: Vector3, tri2: Vector3) -> int:
	tri1 = tri1.round()
	tri2 = tri2.round()
	return (
		int(round(abs(tri1.x - tri2.x)))
		+ int(round(abs(tri1.y - tri2.y)))
		+ int(round(abs(tri1.z - tri2.z)))
	)
