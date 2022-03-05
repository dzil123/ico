extends Node

export(ShaderMaterial) var material

onready var animator = $"../Animator"

onready var img := Image.new()
onready var tex := ImageTexture.new()
var tex_dirty = false

var size: Vector2
var offset: Vector2
var time: float


func _ready():
	set_bounds()
	img.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	reset()

	tex.storage = ImageTexture.STORAGE_RAW
	var flags = 0
	tex.create_from_image(img, flags)

	material.set_shader_param("tex_data", tex)
	material.set_shader_param("tex_data_size", size)
	material.set_shader_param("tex_data_offset", offset)

	animator.connect("completed", self, "animator_completed")


func set_bounds():
	var tiles = PoolVector2Array()
	for tile in $"../Map".get_tiles():
		tiles.append(Vector2(tile.x, tile.y))

	var max_pos = tiles[0]
	var min_pos = tiles[0]

	for tile in tiles:
		max_pos.x = max(max_pos.x, tile.x)
		max_pos.y = max(max_pos.y, tile.y)
		min_pos.x = min(min_pos.x, tile.x)
		min_pos.y = min(min_pos.y, tile.y)

	var margin = Vector2.ONE * 2

	max_pos += margin
	max_pos.x = max(max_pos.x, max_pos.y)
	max_pos.y = max_pos.x

	min_pos -= margin
	min_pos.x = max(min_pos.x, min_pos.y)
	min_pos.y = min_pos.x

	print("max ", max_pos)
	print("min ", min_pos)

	offset = -min_pos
	size = max_pos - min_pos

	print("offset ", offset)
	print("size ", size)


func tri_pos_to_tex(tri_pos: Vector3) -> Vector2:
	var pos = Vector2(tri_pos.x, tri_pos.y) + offset
	assert(0 <= pos.x and pos.x < size.x)
	assert(0 <= pos.y and pos.x < size.y)
	return pos


func reset():
	tex_dirty = true
	img.lock()
	img.fill(Color8(0, 0, 0, 0))
	img.unlock()
	time = 0.0


func animator_completed():
	var ani = animator.ani
	var tri_pos = Tri.pick_tri(ani.next_pos * Vector2(1, -1))

	paint(tri_pos, ani.next_orientation())


func paint(tri_pos: Vector3, orientation: String):
	material.set_shader_param("highlight_tri_pos", tri_pos)

	var color = Octahedron.ORIENTATION_COLOR[orientation]
	tex_dirty = true
	img.lock()
	var pos = tri_pos_to_tex(tri_pos)
	var c = img.get_pixelv(pos)
	if Tri.points_up(tri_pos):
		c.g8 = c.r8
		c.r8 = 1 + color
	else:
		c.a8 = c.b8
		c.b8 = 1 + color
	img.set_pixelv(pos, c)
	img.unlock()


func _process(delta):
	time += delta
	material.set_shader_param("highlight_cart_pos", animator.octa.translation)
	material.set_shader_param("time", time)

	if tex_dirty:
		tex.set_data(img)
		tex_dirty = false
