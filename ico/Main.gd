extends Spatial

#onready var grid = $grid2
#onready var ico = $AnimationPlayer/ico

# distance between two equilateral triangle centers
# https://en.wikipedia.org/wiki/Equilateral_triangle#Principal_properties
# 2 * radius of inscribed circle
const INV_SQRT_3: float = 1 / sqrt(3)

# https://en.wikipedia.org/wiki/Regular_icosahedron#Dimensions
# radius of a circumscribed sphere
const RADIUS_VERTEX: float = sqrt(10.0 + 2.0 * sqrt(5.0)) / 4.0
# radius of an inscribed sphere
const RADIUS_FACE: float = (sqrt(3.0) * (3.0 + sqrt(5.0))) / 12.0
# midradius
const RADIUS_EDGE: float = (1.0 + sqrt(5.0)) / 4.0

var tris = [
	Vector3(1, 0, 0),
	Vector3(1, 1, 0),
	Vector3(0, 1, 0),
	Vector3(0, 1, 1),
	Vector3(0, 0, 1),
	Vector3(1, 0, 1)
]

var tri_pos = Vector3(1, 4, -3)

var index = 0


func _ready():
	for tri in tris:
		var pos = Tri.tri_center(tri)
		print(tri, " ", pos)
	do_update()


func do_update():
#	var pos = Tri.tri_center(tris[index % tris.size()])
	var pos = Tri.tri_center(tri_pos)
	$Indicator.translation.x = pos.x
	$Indicator.translation.z = -pos.y  # invert intentionally because godot

	print("points up: ", Tri.points_up(tri_pos))
	print("tri_pos: ", tri_pos)
	print("cart_pos: ", pos)

func move(delta: Vector3):
	tri_pos += delta
	do_update()

func _input(event):
	if event.is_action_pressed("action"):
		index += 1
		do_update()

	if event.is_action_pressed("move_left"):
		if Tri.points_up(tri_pos):
			move(Vector3(-1, 0, 0))
		else:
			move(Vector3(0, 0, 1))
	if event.is_action_pressed("move_right"):
		if Tri.points_up(tri_pos):
			move(Vector3(0, 0, -1))
		else:
			move(Vector3(1, 0, 0))
	if event.is_action_pressed("move_up"):
		if Tri.points_up(tri_pos):
			pass
		else:
			move(Vector3(0, 1, 0))
	if event.is_action_pressed("move_down"):
		if Tri.points_up(tri_pos):
			move(Vector3(0, -1, 0))
		else:
			pass

	if event is InputEventKey:
		if not event.pressed:
			return
		match event.scancode:
			KEY_R:
				move(Vector3(-1, 0, 0))
			KEY_T:
				move(Vector3(1, 0, 0))
			KEY_F:
				move(Vector3(0, -1, 0))
			KEY_G:
				move(Vector3(0, 1, 0))
			KEY_V:
				move(Vector3(0, 0, -1))
			KEY_B:
				move(Vector3(0, 0, 1))
