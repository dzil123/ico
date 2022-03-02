extends Node

# https://en.wikipedia.org/wiki/Octahedron#Dimensions
const RADIUS_VERTEX = sqrt(2.0) / 2.0
const RADIUS_FACE = sqrt(6.0) / 6.0
const RADIUS_EDGE = 0.5
const ANGLE = PI - acos(-1.0 / 3.0)
# angle between standing on point and lying face flat  # octa
const ANGLE2 = PI / 2.0 - asin(1.0 / sqrt(3.0))

var START_ORIENTATION = "P1"
var START_ROTATION = Basis().rotated(Vector3(0, 1, 0), PI / 4.0).rotated(
	Vector3(1, 0, 0), ANGLE2
)

# ROYGCIVP
# Red     pointy
# Orange  flat
# Yellow  pointy
# Green   flat
# Cyan    flat
# Indigo  pointy
# Violet  flat
# Pink    pointy

enum COLORS_ENUM { R, O, Y, G, C, I, V, P }

const COLORS_NAME = ["R", "O", "Y", "G", "C", "I", "V", "P"]

const ORIENTATION_COLOR = {
	"R1": COLORS_ENUM.R,
	"R2": COLORS_ENUM.R,
	"R3": COLORS_ENUM.R,
	"O1": COLORS_ENUM.O,
	"O2": COLORS_ENUM.O,
	"O3": COLORS_ENUM.O,
	"Y1": COLORS_ENUM.Y,
	"Y2": COLORS_ENUM.Y,
	"Y3": COLORS_ENUM.Y,
	"G1": COLORS_ENUM.G,
	"G2": COLORS_ENUM.G,
	"G3": COLORS_ENUM.G,
	"C1": COLORS_ENUM.C,
	"C2": COLORS_ENUM.C,
	"C3": COLORS_ENUM.C,
	"I1": COLORS_ENUM.I,
	"I2": COLORS_ENUM.I,
	"I3": COLORS_ENUM.I,
	"V1": COLORS_ENUM.V,
	"V2": COLORS_ENUM.V,
	"V3": COLORS_ENUM.V,
	"P1": COLORS_ENUM.P,
	"P2": COLORS_ENUM.P,
	"P3": COLORS_ENUM.P
}

const ORIENTATION_INDEX = {
	"R1": 1,
	"R2": 2,
	"R3": 3,
	"O1": 1,
	"O2": 2,
	"O3": 3,
	"Y1": 1,
	"Y2": 2,
	"Y3": 3,
	"G1": 1,
	"G2": 2,
	"G3": 3,
	"C1": 1,
	"C2": 2,
	"C3": 3,
	"I1": 1,
	"I2": 2,
	"I3": 3,
	"V1": 1,
	"V2": 2,
	"V3": 3,
	"P1": 1,
	"P2": 2,
	"P3": 3
}

# color -> points_up
const POINTY = [true, false, true, false, false, true, false, true]

# orientation -> [result after (1,0,0), result after (0,1,0), result after (0,0,1)]
const GRAPH = {
	"R1": ["O3", "C2", "G1"],
	"R2": ["G2", "O1", "C3"],
	"R3": ["C1", "G3", "O2"],
	"O1": ["I3", "R2", "Y1"],
	"O2": ["Y2", "I1", "R3"],
	"O3": ["R1", "Y3", "I2"],
	"Y1": ["G3", "V2", "O1"],
	"Y2": ["O2", "G1", "V3"],
	"Y3": ["V1", "O3", "G2"],
	"G1": ["P3", "Y2", "R1"],
	"G2": ["R2", "P1", "Y3"],
	"G3": ["Y1", "R3", "P2"],
	"C1": ["R3", "I2", "P1"],
	"C2": ["P2", "R1", "I3"],
	"C3": ["I1", "P3", "R2"],
	"I1": ["C3", "O2", "V1"],
	"I2": ["V2", "C1", "O3"],
	"I3": ["O1", "V3", "C2"],
	"V1": ["Y3", "P2", "I1"],
	"V2": ["I2", "Y1", "P3"],
	"V3": ["P1", "I3", "Y2"],
	"P1": ["V3", "G2", "C1"],
	"P2": ["C2", "V1", "G3"],
	"P3": ["G1", "C3", "V2"]
}

# orientation -> basis
var ROTATIONS = {}


func _ready():
	generate_rotations()


func generate_rotations():
	var MOVES = [Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)]

	var queue = [[[START_ORIENTATION], START_ORIENTATION, START_ROTATION]]

	while ROTATIONS.size() != GRAPH.size():
		var item = queue.pop_front()
		var path: Array = item[0]
		var orientation = item[1]
		var rotation = item[2]

		if ROTATIONS.has(orientation):
			continue

		ROTATIONS[orientation] = rotation

		var multiplier = -1 if POINTY[ORIENTATION_COLOR[orientation]] else 1

		for i in range(3):
			var move = MOVES[i] * multiplier
			var new_orientation = GRAPH[orientation][i]
			var new_path = path + [new_orientation]
			var new_rotation = Grid.apply_rotation(rotation, move)
			queue.push_back([new_path, new_orientation, new_rotation])
