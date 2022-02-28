extends Node

onready var gridmap_pointy: GridMap = $GridMapPointy
onready var gridmap_flat: GridMap = $GridMapFlat

const POINTY_ORIGIN = Vector3(1, 0, 1)
const FLAT_ORIGIN = Vector3(1, 0, 0)

# the y column should be Vector3.ZERO, but instead it is some arbitrary vector
# so that the determinant is not 0, so that there is a valid inverse
# therefore you must assert(gridmap_pos.y == 0)
const POINTY_MAT = Transform(
	Vector3(1, 0, -1), Vector3(1, 0, 0), Vector3(0, -1, 1), POINTY_ORIGIN
)
const FLAT_MAT = Transform(
	Vector3(1, 0, -1), Vector3(1, 0, 0), Vector3(1, -1, 0), FLAT_ORIGIN
)

var POINTY_MAT_INVERSE = POINTY_MAT.affine_inverse()
var FLAT_MAT_INVERSE = FLAT_MAT.affine_inverse()


func _ready():
	assert(POINTY_MAT.basis.determinant() == 1)
	assert(FLAT_MAT.basis.determinant() == 1)


func get_tiles() -> Array:
	var tiles = []

	for cell in gridmap_pointy.get_used_cells():
		assert(cell.y == 0)
		tiles.append(POINTY_MAT * cell)

	for cell in gridmap_flat.get_used_cells():
		assert(cell.y == 0)
		tiles.append(FLAT_MAT * cell)

	return tiles


func in_map(tri_pos: Vector3) -> bool:
	var mat: Transform
	var map: GridMap

	if Tri.points_up(tri_pos):
		map = gridmap_pointy
		mat = POINTY_MAT_INVERSE
	else:
		map = gridmap_flat
		mat = FLAT_MAT_INVERSE

	var cell_pos = mat * tri_pos
	var cell = map.get_cell_item(cell_pos.x, cell_pos.y, cell_pos.z)

	return cell >= 0
