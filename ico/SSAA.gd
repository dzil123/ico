extends ViewportContainer

enum SSAA { x1, x2, x4 }
export(SSAA) var ssaa = SSAA.x4

onready var viewport_outer = $ViewportOuter
onready var viewport_inner = $ViewportOuter/ViewportInnerContainer/ViewportInner

const SCALE_LOOKUP = [Vector2(1, 1), Vector2(1, 2), Vector2(2, 4)]


func _ready():
	viewport_outer.get_texture().flags = Texture.FLAG_FILTER
	viewport_inner.get_texture().flags = Texture.FLAG_FILTER

	get_viewport().connect("size_changed", self, "_root_viewport_size_changed")

	apply_ssaa()


func apply_ssaa():
	print("scale: ", OS.get_screen_scale())
	if OS.get_screen_scale() > 1.5:
		ssaa = SSAA.x1
		print("no ssaa")
	print("ssaa: ", ssaa)

	_root_viewport_size_changed()


func _root_viewport_size_changed():
	var size = get_viewport().size
	var scale = SCALE_LOOKUP[ssaa]

	viewport_outer.size = size * scale.x
	viewport_inner.size = size * scale.y
