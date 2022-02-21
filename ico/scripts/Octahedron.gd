extends Node

# https://en.wikipedia.org/wiki/Octahedron#Dimensions
const RADIUS_VERTEX = sqrt(2.0) / 2.0
const RADIUS_FACE = sqrt(6.0) / 6.0
const RADIUS_EDGE = 0.5
const ANGLE = PI - acos(-1.0 / 3.0)
# angle between standing on point and lying face flat  # octa
const ANGLE2 = PI / 2.0 - asin(1.0 / sqrt(3.0))

var START_ROTATION = Basis().rotated(Vector3(0, 1, 0), PI / 4.0).rotated(
	Vector3(1, 0, 0), ANGLE2
)
