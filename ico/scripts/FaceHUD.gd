extends Control
tool

export(Octahedron.COLORS_ENUM) var color = Octahedron.COLORS_ENUM.R setget set_color
export(int, 1, 3) var orientation_index = 1 setget set_orientation_index
export(Texture) var tex
export(bool) var is_ready = false
export(float, 0.05, 5) var scale = 100
export(String) var orientation setget set_orientation


const HEIGHT = 1.0 / (2.0 * sqrt(3.0))
const FLAT = PoolVector2Array(
	[Vector2(-0.5, HEIGHT), Vector2(0, -2.0 * HEIGHT), Vector2(0.5, HEIGHT)]
)
const POINTY = PoolVector2Array(
	[Vector2(0.5, -HEIGHT), Vector2(0, 2.0 * HEIGHT), Vector2(-0.5, -HEIGHT)]
)

const CENTERS = [POINTY, FLAT]
const POINTS = [FLAT, POINTY]

var uvs = []


func _init():
	is_ready = false
	print("_init")


func _ready():
	is_ready = false
	print("_ready")


func ready():
	print("ready()")
#	var start = Vector3(1, 1, 0)
#
#	for new in Tri.tri_neighbors(start):
#		var delta = new - start
#		var pos = Tri.tri_center(start) - Tri.tri_center(new)
#		print(start, " ", delta, " ", new, " ", pos)
#
#	print(POINTY)

	for i in range(8):
		var x = (2 * i + 1) / float(2 * 8)
		var v = Vector2(x, 0.8)
		uvs.append(PoolVector2Array([v, v, v]))


func _process(_delta):
	update()


func set_orientation(new_orientation: String):
	orientation = new_orientation
	color = Octahedron.ORIENTATION_COLOR[new_orientation]
	orientation_index = Octahedron.ORIENTATION_INDEX[new_orientation]

func set_color(new_color: int):
	color = new_color
	orientation = Octahedron.COLORS_NAME[color] + str(orientation_index)


func set_orientation_index(new_orientation_index: int):
	orientation_index = new_orientation_index
	orientation = Octahedron.COLORS_NAME[color] + str(orientation_index)


func translate_pos(pos: Vector2, global_pointy: bool):
	var y_offset = HEIGHT * (1 if global_pointy else -1) * Vector2.DOWN
	pos += y_offset
	return (pos * scale + Vector2(1, -1) * 0.5) * rect_size.x * Vector2(1, -1)


func draw_tri(pos: Vector2, pointy: bool, global_pointy: bool, color: int):
	var pts = POINTS[int(pointy)]

	draw_set_transform(translate_pos(pos, global_pointy), 0, rect_size.x * scale * Vector2(1, -1))
	draw_primitive(pts, PoolColorArray(), uvs[color], tex)


func _draw():
	if not is_ready:
		ready()
		is_ready = true

	if tex == null:
		return

	var pointy = Octahedron.POINTY[color]
	
	draw_tri(Vector2.ZERO, pointy, pointy, color)
	
	var centers = CENTERS[int(pointy)]
	var o = orientation
	var neighbors = Octahedron.GRAPH[o]

	for i in range(3):
		var color = Octahedron.ORIENTATION_COLOR[neighbors[i]]
		
		draw_tri(centers[i], not pointy, pointy, color)
