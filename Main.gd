extends Node

var image = File.new()
var loadedImage

var deck = []
var field = []

export (PackedScene) var Card

func make_deck():
	var dir = Directory.new()
	if dir.open("res://Cards") == OK:
		var card_file = File.new()
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			card_file.open("res://Cards/" + file_name, card_file.READ)
			var card = Card.instance()
			var next_attr = card_file.get_csv_line(":")
			while !card_file.eof_reached():
				card.set(next_attr[0], next_attr[1])
				next_attr = card_file.get_csv_line(":")
			card_file.close()
			deck.append(card)
			file_name = dir.get_next()
		dir.list_dir_end()

func draw_card():
	var draw = deck.pop_front()
	loadedImage = load("res://Card Art/" + draw.IMAGE)
	draw.get_child(0).set_texture(loadedImage)
	var sizeDraw = Vector2(loadedImage.get_size())
	sizeDraw.x = 128 / sizeDraw.x
	sizeDraw.y = 128 / sizeDraw.y
	draw.get_child(0).set_scale(sizeDraw)
	field.append(draw)
	get_node("Field_PS").add_child(draw)
	draw.get_child(2).append_bbcode("[center][color=black]" + draw.NAME + "[/color][/center]")
	draw_field(get_node("Field_PS"), 50)
	
func draw_field(field_node, gap):
	var num_cards = field_node.get_child_count() - 1
	var length = -465
	var offset = -465 + ((num_cards * (128 + gap) - gap) / 2) - 64
	for i in num_cards:
		var card = field_node.get_child(i+1)
		card.position = Vector2(length - offset, 0)
		length += 128 + gap
	
func shuffle_deck():
	var temp_deck = []
	while len(deck) > 0:
		var i = randi() % len(deck)
		temp_deck.append(deck[i])
		deck.remove(i)
	deck = temp_deck

func _ready():
	randomize()
	make_deck()
	shuffle_deck()

func _process(delta):
	pass