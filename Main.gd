extends Node

var image = File.new()
var loadedImage

var deck_0 = []
var deck_1 = []

var phase = [0, "Draw"]

export (PackedScene) var Card

func make_deck(deck):
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
	return deck

func draw_card(deck, field):
	var draw = deck.pop_front()
	loadedImage = load("res://Card Art/" + draw.IMAGE)
	draw.get_child(0).set_texture(loadedImage)
	var sizeDraw = Vector2(loadedImage.get_size())
	sizeDraw.x = 128 / sizeDraw.x
	sizeDraw.y = 128 / sizeDraw.y
	draw.get_child(0).set_scale(sizeDraw)
	field.add_child(draw)
	draw.get_child(2).append_bbcode("[center][color=black]" + draw.NAME + "[/color][/center]")
	draw_field(field, 50)
	
func draw_field(field_node, gap):
	var num_cards = field_node.get_child_count() - 1
	var length = -465
	var offset = -465 + ((num_cards * (128 + gap) - gap) / 2) - 64
	for i in num_cards:
		var card = field_node.get_child(i+1)
		card.position = Vector2(length - offset, 0)
		length += 128 + gap
	
func shuffle_deck(deck):
	var temp_deck = []
	while len(deck) > 0:
		var i = randi() % len(deck)
		temp_deck.append(deck[i])
		deck.remove(i)
	return temp_deck
	
func mouse_input(object):
	if object.get_parent() == get_child(phase[0]):
		if object.get_name() == "Deck":
			if phase[1] == "Draw":
				draw_card(get("deck_" + str(phase[0])), get_child(phase[0]).get_node("Field"))
				phase[1] = "End"
			else:
				print("You can't do that right now.")
		elif object.get_name() == "End":
			phase[0] = int(!phase[0])
			phase[1] = "Draw"
	else:
		print("It is not your turn.")

func _ready():
	randomize()
	deck_0 = make_deck(deck_0)
	deck_1 = make_deck(deck_1)
	deck_0 = shuffle_deck(deck_0)
	deck_1 = shuffle_deck(deck_1)
	
	var num_sides = get_child_count()
	for i in num_sides:
		var num_nodes = get_child(i).get_child_count()
		for j in num_nodes:
			var curr = get_child(i).get_child(j)
			if curr.get_class() == "Area2D":
				curr.connect("click", self, "mouse_input", [curr])