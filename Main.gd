extends Node

var field = []
var image = File.new()
var loadedImage

var names = ["Prince Keleseth", "Divine Commander", "Razorfen Hunter", "Argent Commander", "Prince Liam", "Stonetusk Golem", "Jaxxarus", "Tar Lord"]
var pics = ["pk.jpg", "dc.png", "rh.jpg", "ac.png", "pl.png", "sc.jpg", "j.jpg", "tl.jpg"]

export (PackedScene) var Card

func draw_card():
	var draw = Card.instance()
	draw.NAME = str(randi() % len(names))
	loadedImage = load("res://Card Art/" + pics[int(draw.NAME)])
	draw.get_child(0).set_texture(loadedImage)
	var sizeDraw = Vector2(loadedImage.get_size())
	sizeDraw.x = 128 / sizeDraw.x
	sizeDraw.y = 128 / sizeDraw.y
	draw.get_child(0).set_scale(sizeDraw)
	field.append(draw)
	add_child(draw)
	draw.connect("click", self, "draw_card")
	draw.global_position = Vector2(randi() % 1024, randi() % 600)
	draw.get_child(2).append_bbcode("[center][color=black]" + names[int(draw.NAME)] + "[/color][/center]")
	names.remove(int(draw.NAME))
	pics.remove(int(draw.NAME))

func _ready():
	randomize()
	draw_card()

func _process(delta):
	pass