# Inheritance
extends Node

# Globals 
var deck_0 = [] # Player's Deck
var deck_1 = [] # Enemy's Deck
var phase = [0, "Draw"] # [0] = player, [1] = turn phase

var effect_function
var battle_function
var legal_fields = []

var temp_overload

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
	draw.get_node("Art").set_texture(loadedImage)
	var sizeDraw = Vector2(loadedImage.get_size())
	sizeDraw.x = 128 / sizeDraw.x
	sizeDraw.y = 128 / sizeDraw.y
	draw.get_node("Art").set_scale(sizeDraw)
	field.add_child(draw)
	update_bbcode(draw)
	draw_field(field, 50)
	
func update_bbcode(card):
	card.get_node("Infotext").parse_bbcode("[center][color=black]" + card.NAME)
	card.get_node("Occupie").parse_bbcode("[u][color=red]" + str(card.OCCUPANCY))
	card.get_node("Invul_Decal").visible = card.INVUL
	
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
	
func default_card(card):
	card.OCCUPANCY = 1
	card.INVUL = false
	update_bbcode(card)
	
func select_target():
	
	for i in legal_fields:
		var card_count = i.get_children()
		for j in card_count:
			if j.get_filename() == Card.get_path():
				j.get_node("Target_Decal").visible = true
	
	print("Select a target")
	yield()
	print("Good job.")
	
	for i in legal_fields:
		var card_count = i.get_children()
		for j in card_count:
			if j.get_filename() == Card.get_path():
				j.get_node("Target_Decal").visible = false
	
func activate_effect(card):
	var target_names = ["self"]
	var target_cards = [card]
	var target
	
	var effect = card.LIGHT_EFFECT.split(",")
	
	if int(effect[0]) == 0:
		target = target_cards[target_names.find(effect[1])]
	else:
		var restriction = effect[1].split("/")
		legal_fields = []
		for i in restriction[0]:
			var side = phase[0]
			if i == "1":
				side = (side - 1) * -1
			legal_fields.append(get_child(side).get_node("Shadow_Field"))
			legal_fields.append(get_child(side).get_node("Light_Field"))
		for i in restriction[1]:
			var j = (int(i) - 1) * -1
			while j < len(legal_fields):
				legal_fields.remove(j)
				j += 1
				
		var select_function = select_target()
		target = yield()
		select_function.resume()
		
	if effect[2] == "occ":
		target.OCCUPANCY += int(effect[3])
	elif effect[2] == "inv":
		target.INVUL = true
	else:
		print(effect[2])
		
	update_bbcode(target)
		
	return card
	
func display_occupancys(allies, enemies):
	var curr_enemy = 0
	
	while curr_enemy < len(enemies) and enemies[curr_enemy].get_filename() != Card.get_path():
		curr_enemy += 1
		
	var enemy_alive = true
	var excess_occupancy = 0
	
	for i in allies:
		if i.get_filename() == Card.get_path():
			while i.OCCUPANCY > 0:
				i.OCCUPANCY -= 1
				if enemy_alive:
					update_bbcode(i)
					enemies[curr_enemy].OCCUPANCY -= 1
					update_bbcode(enemies[curr_enemy])
					get_node("Sleep").start()
					yield(get_node("Sleep"), "timeout")
					print("Im' back")
					if enemies[curr_enemy].OCCUPANCY <= 0:
						curr_enemy += 1
						if curr_enemy >= len(enemies):
							print("You win.")
							enemy_alive = false
				else:
					excess_occupancy += 1

	temp_overload = excess_occupancy

func battle_phase():
	var allies = get_child(phase[0]).get_node("Light_Field").get_children()
	var enemies = get_child((phase[0] - 1) * -1).get_node("Light_Field").get_children()
	
	if len(allies) == 1:
		print("There is nothing you can do.")
	elif len(enemies) == 1:
		print("You styll win, hol up.")
	else:
		display_occupancys(allies, enemies)
		var kill_power = yield()
		print("Thanks.")
		if kill_power > 0:
			print("You may destroy ", kill_power, " targets.")
			legal_fields = [enemies[0].get_parent()]
			var select_function = select_target()
			var target = yield()
			select_function.resume()
			# legal_fields[0].remove_child(target)
			print(target.NAME, " was removed.")
			draw_field(legal_fields[0], 50)
		else:
			print("You don't win.")
		# get_node("Sleep").start()
		# yield(get_node("Sleep"), "timeout")
			
		for i in allies:
			if i.get_filename() == Card.get_path():
				default_card(i)

		for i in enemies:
			if i.get_filename() == Card.get_path():
				default_card(i)

	phase[1] = "End"
	
	battle_function = null

func send_target(object, resume_function):
	if object.get_filename() == Card.get_path() and object.get_parent() in legal_fields:
		object = resume_function.resume(object)
		print(object)
		return object
	else:
		print("That is not a valid target.")
		return null
		
# function to catch GUI input and decide what to do
func mouse_input(object):
	if phase[1] == "Activate":
		object = send_target(object, effect_function)
		if object != null:
			move_card(object, get_child(phase[0]), "Light_Field")
			phase[1] = "Prep"
	elif phase[1] == "Battle":
		send_target(object, battle_function)
#		if battle_function is GDScriptFunctionState:
#			print("1", battle_function.is_valid())
#			print("2", battle_function.is_valid(true))
#			battle_function.resume(object)
#		else:
#			print("Nope")
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
				if phase[1] == "Prep":
					phase[1] = "Battle"
					battle_function = battle_phase()
				elif phase[1] == "End":
					phase[0] = (phase[0] - 1) * -1
					phase[1] = "Draw"
				else:
					print(phase[1])
					print("You can't do that right now.")
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
				
func _process(delta):
	if temp_overload != null:
		print("let's try it")
		print(battle_function)
		var meme_func = battle_function.resume(temp_overload)
		if not(battle_function.is_valid(true)):
			battle_function = meme_func
			print(battle_function.is_valid(true), " ", phase[1])
		temp_overload = null
		
