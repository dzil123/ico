class_name Ani
extends Resource

export(Vector2) var prev_pos
export(Vector2) var next_pos
export(Vector3) var rotation_axis
export(String) var prev_orientation
export(Vector3) var delta


func inverse() -> Ani:
	var inverse = duplicate()  # cant call Ani.new()?
	inverse.prev_pos = next_pos
	inverse.next_pos = prev_pos
	inverse.rotation_axis = -rotation_axis
	var move = Grid.delta_to_move(delta)
	inverse.prev_orientation = next_orientation()
	inverse.delta = -delta
	return inverse


func move() -> int:
	return Grid.delta_to_move(delta)


func next_orientation() -> String:
	return Octahedron.GRAPH[prev_orientation][move()]
