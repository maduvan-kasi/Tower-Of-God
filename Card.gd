extends Area2D

export(String) var NAME
export(String) var IMAGE
export(String) var LIGHT_EFFECT

var screensize

signal click

func _ready():
	screensize = get_viewport_rect().size

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		emit_signal("click")

func _process(delta):
	pass