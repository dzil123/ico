class_name ShapeConfig

extends Resource

export(String) var name
# radius of a circumscribed sphere
var RADIUS_VERTEX: float
# radius of an inscribed sphere
var RADIUS_FACE: float
# midradius
var RADIUS_EDGE: float
# 180 - dihedral angle
var ANGLE: float
var START_ROTATION: Basis


func _init():
	init()


func init():
	push_error("YOU DIDNT OVERRIDE")
