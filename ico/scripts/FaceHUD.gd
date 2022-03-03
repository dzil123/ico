extends Control
tool

export(Texture) var m_tex
export(float, 0.05, 5) var m_scale = 100
export(float, 0.5, 1) var m_local_scale = 1
export(String) var m_orientation = "R1"
export(int, 0, 2) var m_move = 0
export(float, 0, 1) var m_percent_anim = 0
#export(Color) var m_bg_color = Color("282f36")
#export(Color) var m_border_color = Color.white

const HEIGHT = sqrt(3) / 6
const FLAT = PoolVector2Array(
	[Vector2(-0.5, HEIGHT), Vector2(0, -2.0 * HEIGHT), Vector2(0.5, HEIGHT)]
)
const POINTY = PoolVector2Array(
	[Vector2(0.5, -HEIGHT), Vector2(0, 2.0 * HEIGHT), Vector2(-0.5, -HEIGHT)]
)

const CENTERS = [POINTY, FLAT]
const POINTS = [FLAT, POINTY]

var m_is_ready = false
var m_uvs = []


func _ready():
	m_is_ready = true
	m_uvs = []

	for i in range(8):
		var x = (2 * i + 1) / float(2 * 8)
		var v = Vector2(x, 0.8)
		m_uvs.append(PoolVector2Array([v, v, v]))


func _process(_delta):
	update()


func translate_pos(pos: Vector2):
	return (pos * m_scale + Vector2(1, -1) * 0.5) * rect_size.x * Vector2(1, -1)


static func with_alpha(color: Color, alpha: float) -> PoolColorArray:
	color.a = alpha
	return PoolColorArray([color])


func draw_tri(pos: Vector2, pointy: bool, color: int, alpha: float):
	var verts = POINTS[int(pointy)]

	var final_pos = translate_pos(pos)
	var final_scale = rect_size.x * m_scale * m_local_scale * Vector2(1, -1)

#	draw_set_transform(final_pos, 0, final_scale / m_local_scale)
#	draw_primitive(verts, with_alpha(m_border_color, alpha), PoolVector2Array())
	draw_set_transform(final_pos, 0, final_scale)
#	draw_primitive(verts, with_alpha(m_bg_color, alpha), PoolVector2Array())
	draw_primitive(verts, with_alpha(Color.white, alpha), m_uvs[color], m_tex)


func draw_single(pos: Vector2, orientation: String):
	var color = Octahedron.ORIENTATION_COLOR[orientation]
	var pointy = Octahedron.POINTY[color]

	draw_tri(pos, pointy, color, 1)

	return pointy


func draw_set(pos: Vector2, orientation: String, alpha: float):
	var pointy = draw_single(pos, orientation)

	var centers = CENTERS[int(pointy)]
	var neighbors = Octahedron.GRAPH[orientation]

	for i in range(3):
		var neighbor_color = Octahedron.ORIENTATION_COLOR[neighbors[i]]

		draw_tri(pos + centers[i], not pointy, neighbor_color, alpha)


func _draw():
	if m_tex == null:
		return

	var pointy = Octahedron.POINTY[Octahedron.ORIENTATION_COLOR[m_orientation]]
	var new_center = CENTERS[int(pointy)][m_move]
	var new_orientation = Octahedron.GRAPH[m_orientation][m_move]

	var percent = m_percent_anim * m_percent_anim * (3 - 2 * m_percent_anim)
	var start_pos = Vector2.ZERO.linear_interpolate(-new_center, percent)
	var end_pos = start_pos + new_center

	draw_set(start_pos, m_orientation, 1 - percent)
	draw_set(end_pos, new_orientation, percent)

#	draw_single(start_pos, m_orientation)
#	draw_single(end_pos, new_orientation)
