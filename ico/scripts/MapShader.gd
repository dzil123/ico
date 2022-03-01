extends Node

export(ShaderMaterial) var material

onready var game = $".."


func _process(_delta):
	material.set_shader_param("highlight_tri_pos", game.tri_pos)
