# Inheritance
extends Node

# Globals 
var deck_0 = [] # Player's Deck
var deck_1 = [] # Enemy's Deck
var phase = [0, "Draw"] # [0] = player, [1] = turn phase

var effect_function

# Exports
export (PackedScene) var Card

# function to create list of Card objects [from hard folder]
func make_deck(deck):
	var dir = Directory.new()
	if dir.open("res://Cards") == OK:
		var card_file = File.new()
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			card_file.open("res://Cards/" + file_name, card_file.READ)
			var card = Card.instance()
			var ended = false
			var next_attr = card_file.get_csv_line(":")
			while !ended:
				card.set(next_attr[0], next_attr[1])
				if !card_file.eof_reached():
					next_attr = card_file.get_csv_line(":")
				else:
					ended = true
			card_file.close()
			card.connect("click", self, "mouse_input", [card])
			deck.append(card)
			file_name = dir.get_next()
		dir.list_dir_end()
	return deck

# function to remove Card from list and add to Field
func draw_card(deck, field):
	var draw = deck.pop_front()
	var loadedImage = load("res://Card Art/" + draw.IMAGE)
	draw.get_child(0).set_texture(loadedImage)
	var sizeDraw = Vector2(loadedImage.get_size())
	sizeDraw.x = 128 / sizeDraw.x
	sizeDraw.y = 128 / sizeDraw.y
	draw.get_child(0).set_scale(sizeDraw)
	field.add_child(draw)
	update_bbcode(draw)
	draw_field(field, 50)
	
func update_bbcode(card):
	card.get_child(2).append_bbcode(card.NAME)
	card.get_child(4).append_bbcode(str(card.OCCUPIABILITY))
	
# function to rearrange Cards in Field (graphically)
func draw_field(field_node, gap):
	var num_cards = field_node.get_child_count() - 1
	var length = -465
	var offset = -465 + ((num_cards * (128 + gap) - gap) / 2) - 64
	for i in num_cards:
		var card = field_node.get_child(i+1)
		card.position = Vector2(length - offset, 0)
		length += 128 + gap
	
# function to randomly reorder the elements in a list
func shuffle_deck(deck):
	var temp_deck = []
	while len(deck) > 0:
		var i = randi() % len(deck)
		temp_deck.append(deck[i])
		deck.remove(i)
	return temp_deck
	
# function to move Card from Shadow/Light Field to the other
func move_card(card, side, dest_field):
	card.get_parent().remove_child(card)
	side.get_node(dest_field).add_child(card)
	update_bbcode(card)
	draw_field(side.get_node("Shadow_Field"), 50)
	draw_field(side.get_node("Light_Field"), 50)
	
func activate_effect(card):
	var target_names = ["self"]
	var target_cards = [card]
	var target
	
	var effect = card.LIGHT_EFFECT.split(",")
	
	if int(effect[0]) == 0:
		target = target_cards[target_names.find(effect[1])]
	else:
		print("Select a target")
		target = yield()
	if effect[2] == "occ":
		target.OCCUPIABILITY += int(effect[3])
	else:
		print(effect[2])
	return card
	
# function to catch GUI input and decide what to do
func mouse_input(object):
	if phase[1] == "Activate":
		if object.get_filename() == Card.get_path():
			object = effect_function.resume(object)
			move_card(object, get_child(phase[0]), "Light_Field")
			phase[1] = "Prep"
		else:
			print("That is not a valid target.")
	else:
		if get_child(phase[0]).is_a_parent_of(object):
			if object.get_name() == "Deck":
				if phase[1] == "Draw":
					draw_card(get("deck_" + str(phase[0])), get_child(phase[0]).get_node("Shadow_Field"))
					phase[1] = "Prep"
				else:
					print("You can't do that right now.")
			elif object.get_parent().get_name() == "Shadow_Field":
				if phase[1] == "Prep":
					phase[1] = "Activate"
					effect_function = activate_effect(object)
					if not(effect_function is GDScriptFunctionState):
						move_card(object, get_child(phase[0]), "Light_Field")
						phase[1] = "Prep"
			elif object.get_name() == "End":
				phase[0] = (phase[0] - 1) * -1
				phase[1] = "Draw"
			else:
				pass
		else:
			print("It is not your turn.")

func _ready():
	
	# Initialize Decks
	randomize()
	deck_0 = make_deck(deck_0)
	deck_1 = make_deck(deck_1)
	deck_0 = shuffle_deck(deck_0)
	deck_1 = shuffle_deck(deck_1)
	
	# Connect GUI signals from drag-drop objects
	var num_sides = get_child_count()
	for i in num_sides:
		var num_nodes = get_child(i).get_child_count()
		for j in num_nodes:
			var curr = get_child(i).get_child(j)
			if curr.get_class() == "Area2D":
				curr.connect("click", self, "mouse_input", [curr])