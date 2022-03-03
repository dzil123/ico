extends Node

export(ShaderMaterial) var material

const SIZE = Vector2(40, 40)
const OFFSET = Vector2(10, 0)

onready var game = $".."

onready var img := Image.new()
onready var tex := ImageTexture.new()
var tex_dirty = false

var last_pos = null


func _ready():
	img.create(int(SIZE.x), int(SIZE.y), false, Image.FORMAT_RGBA8)
	reset()

	tex.storage = ImageTexture.STORAGE_RAW
	var flags = 0
	tex.create_from_image(img, flags)

	material.set_shader_param("tex_data", tex)
	material.set_shader_param("tex_data_size", SIZE)
	material.set_shader_param("tex_data_offset", OFFSET)


func tri_pos_to_tex(tri_pos: Vector3) -> Vector2:
	var pos = Vector2(tri_pos.x, tri_pos.y) + OFFSET
	assert(0 <= pos.x and pos.x < SIZE.x)
	assert(0 <= pos.y and pos.x < SIZE.y)
	return pos


func reset():
	tex_dirty = true
	img.lock()
	img.fill(Color8(0, 0, 0, 0))
	img.unlock()


func _process(_delta):
	material.set_shader_param("highlight_tri_pos", game.tri_pos)

	if last_pos == null or last_pos != game.tri_pos:
		last_pos = game.tri_pos

		var color = Octahedron.ORIENTATION_COLOR[game.orientation]
		tex_dirty = true
		img.lock()
		var pos = tri_pos_to_tex(game.tri_pos)
		var c = img.get_pixelv(pos)
		if Tri.points_up(game.tri_pos):
			c.g8 = c.r8
			c.r8 = 1 + color
		else:
			c.a8 = c.b8
			c.b8 = 1 + color
		img.set_pixelv(pos, c)
		img.unlock()

	if tex_dirty:
		tex.set_data(img)
		tex_dirty = false
