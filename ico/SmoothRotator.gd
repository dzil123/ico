extends Spatial

export(NodePath) var controller
export(bool) var interpolate = true
export(float) var interpolation_strength = 10.0


func _process(delta):
	if controller.is_empty():
		return

	if interpolate:
		var curr = transform.basis.get_rotation_quat()
		var final = get_node(controller).transform.basis.get_rotation_quat()
		var next = curr.slerp(final, interpolation_strength * delta)
		transform.basis = Basis(next)

		var curr_pos = transform.origin
		var final_pos = get_node(controller).transform.origin
		var next_pos = curr_pos.linear_interpolate(
			final_pos, interpolation_strength * delta
		)
		transform.origin = next_pos
	else:
		transform.basis = get_node(controller).transform.basis
		transform.origin = get_node(controller).transform.origin
