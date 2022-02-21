extends Node

signal completed

export(NodePath) var follower_path
export(float) var duration = 1.5  # seconds per move

var is_moving := false
var percent_elapsed := 0.0  # 0 to 1
var ani: Ani


func _ready():
	print("ANIMATOR:")
	var c = Octahedron
	print(c.RADIUS_VERTEX)
	print(c.RADIUS_FACE)
	print(c.RADIUS_EDGE)
	print(c.ANGLE)
	print("end")


func _process(delta):
	if not is_moving:
		percent_elapsed = 0.0
		return
	percent_elapsed += delta / duration
	if percent_elapsed < 1.0:
		apply_follower(percent_elapsed)
		return
	apply_follower(1.0)

	percent_elapsed -= 1.0
	is_moving = false
	emit_signal("completed")


func apply_follower(percent: float):
	var follower = get_node(follower_path) as Spatial
	follower.transform = calculate(percent)


func calculate(percent: float) -> Transform:
	var basis = ani.prev_basis.rotated(ani.rotation_axis, percent * Octahedron.ANGLE)

	# assume flat ground
	# angle_start, angle_end, angle_lerped
	var a_start = (PI - Octahedron.ANGLE) / 2.0
	var a_end = (PI + Octahedron.ANGLE) / 2.0
	var a_lerped = lerp(a_start, a_end, percent)

	var horizontal_percent = (1.0 - (cos(a_lerped) / cos(a_start))) / 2.0
	var vertical_percent = (sin(a_lerped) - sin(a_start)) / (1.0 - sin(a_start))

	var pos = ani.prev_pos.linear_interpolate(ani.next_pos, horizontal_percent)
	var height = lerp(Octahedron.RADIUS_FACE, Octahedron.RADIUS_EDGE, vertical_percent)

	var translation = Vector3(pos.x, height, pos.y)

	return Transform(basis, translation)


func start(new_ani: Ani):
	print("ani start")
	if is_moving:
		cancel()
	ani = new_ani
	is_moving = true


func cancel():
	print("ani cancel")
	if is_moving:
		apply_follower(1.0)
	is_moving = false
	percent_elapsed = 0.0
