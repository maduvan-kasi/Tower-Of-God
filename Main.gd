extends Node

var spot = 100
var field = []
var image = File.new()
var loadedImage

export (PackedScene) var Card

func _ready():
	randomize()
	var draw = Card.instance()
	draw.NAME = str(randi() % 8)
	if image.file_exists("res://Card Art/" + draw.NAME + ".jpg"):
		loadedImage = load("res://Card Art/" + draw.NAME + ".jpg")
	else:
		loadedImage = load("res://Card Art/" + draw.NAME + ".png")
	draw.get_child(0).set_texture(loadedImage)
	var sizeDraw = Vector2(loadedImage.get_size())
	sizeDraw.x = 128 / sizeDraw.x
	sizeDraw.y = 128 / sizeDraw.y
	draw.get_child(0).set_scale(sizeDraw)
	field.append(draw)
	add_child(draw)
	draw.connect("click", self, "_yeet")
	draw.global_position = Vector2(randi() % 1024, randi() % 600)

func _process(delta):
	pass


func _yeet():
	var draw = Card.instance()
	draw.NAME = str(randi() % 8)
	if image.file_exists("res://Card Art/" + draw.NAME + ".jpg"):
		loadedImage = load("res://Card Art/" + draw.NAME + ".jpg")
	else:
		loadedImage = load("res://Card Art/" + draw.NAME + ".png")
	draw.get_child(0).set_texture(loadedImage)
	var sizeDraw = Vector2(loadedImage.get_size())
	sizeDraw.x = 128 / sizeDraw.x
	sizeDraw.y = 128 / sizeDraw.y
	draw.get_child(0).set_scale(sizeDraw)
	field.append(draw)
	add_child(draw)
	draw.connect("click", self, "_yeet")
	draw.global_position = Vector2(randi() % 1024, randi() % 600)
