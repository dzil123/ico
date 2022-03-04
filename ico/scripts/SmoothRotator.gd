extends Spatial

export(NodePath) var controller
export(bool) var interpolate = true
export(float) var interpolation_strength = 10.0
export(bool) var follow_transform = false
export(bool) var follow_basis = false


func _process(delta):
	if controller.is_empty():
		return

	if interpolate:
		if follow_basis:
			var curr = transform.basis.get_rotation_quat()
			var final = get_node(controller).transform.basis.get_rotation_quat()
			var next = curr.slerp(final, interpolation_strength * delta)
			transform.basis = Basis(next)

		if follow_transform:
			var curr_pos = transform.origin
			var final_pos = get_node(controller).transform.origin
			var next_pos = curr_pos.linear_interpolate(
				final_pos, interpolation_strength * delta
			)
			transform.origin = next_pos
	else:
		if follow_basis:
			transform.basis = get_node(controller).transform.basis
		if follow_transform:
			transform.origin = get_node(controller).transform.origin
