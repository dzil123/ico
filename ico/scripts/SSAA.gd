extends ViewportContainer

enum SSAA { x1, x2, x4 }
export(SSAA) var ssaa = SSAA.x4

export(NodePath) var joystick_path

onready var viewport_outer = $ViewportOuter
onready var viewport_inner = $ViewportOuter/ViewportInnerContainer/ViewportInner
onready var joystick = get_node(joystick_path)
onready var root = $".."
onready var is_portrait = tell_portrait()

const SCALE_LOOKUP = [Vector2(1, 1), Vector2(1, 2), Vector2(2, 4)]


func _ready():
	viewport_outer.get_texture().flags = Texture.FLAG_FILTER
	viewport_inner.get_texture().flags = Texture.FLAG_FILTER

	get_viewport().connect("size_changed", self, "_root_viewport_size_changed")

	apply_ssaa()

	if not is_portrait:
		joystick.hide()


func apply_ssaa():
	var screen_scale = OS.get_screen_scale()
	print("screen_scale: ", screen_scale)
	if screen_scale > 1.5:
		ssaa = SSAA.x1
		print("no ssaa")
	print("ssaa: ", ssaa)

	call_deferred("_root_viewport_size_changed")


func _root_viewport_size_changed():
	var raw_size = get_viewport().size
	var flipped_size = Vector2(raw_size.y, raw_size.x)
	var size: Vector2  # landscape size of the 3d viewport

	if is_portrait:
		size = flipped_size
		root.rect_position.x = size.y
		root.rect_rotation = 90
	else:
		size = raw_size
		root.rect_position.x = 0
		root.rect_rotation = 0

	root.rect_size = size

	var scale = SCALE_LOOKUP[ssaa]

	viewport_outer.size = size * scale.x
	viewport_inner.size = size * scale.y


func tell_portrait():
	var size = get_viewport().size
	return size.y > size.x
