extends Node

signal completed

export(NodePath) var octa_path
export(NodePath) var facehub_path
export(float) var duration = 1.5  # seconds per move
export(float, 1.0, 10.0) var action_length_constant = 1.0

onready var octa = get_node(octa_path) as Spatial
onready var facehud = get_node(facehub_path)

var is_moving := false
var percent_elapsed := 0.0  # 0 to 1
var ani: Ani
var speed = 1.0


func _process(delta):
	if not is_moving:
		percent_elapsed = 0.0
		return
	percent_elapsed += delta * speed / duration
	if percent_elapsed < 1.0:
		apply_follower(percent_elapsed)
		return
	apply_follower(1.0)

	percent_elapsed -= 1.0
	is_moving = false
	emit_signal("completed")


func apply_follower(percent: float):
	octa.transform = calculate(percent)

	facehud.m_orientation = ani.prev_orientation
	facehud.m_move = Grid.delta_to_move(ani.delta)
	facehud.m_percent_anim = percent


func calculate(percent: float) -> Transform:
	var prev_basis = Octahedron.ROTATIONS[ani.prev_orientation]
	var basis = prev_basis.rotated(ani.rotation_axis, percent * Octahedron.ANGLE)

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
	if is_moving:
		cancel()
	ani = new_ani
	is_moving = true


func cancel():
	if is_moving:
		apply_follower(1.0)
	is_moving = false
	percent_elapsed = 0.0
	speed = 1.0


func action_length(size: int):
	speed = exp(float(size) / action_length_constant)
