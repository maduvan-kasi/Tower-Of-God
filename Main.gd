"""To-Do
 - Soft Code sizes
	- Screen Size
	- Card Size
 - Enumerate removal during battle
"""

# Inheritance
extends Node

# Globals 
var deck_0 = [] # Player's Deck
var deck_1 = [] # Enemy's Deck
var phase = [0, "Draw"] # [0] = player, [1] = turn phase
var legal_fields = [] # For targeting purposes

# Yield Function Placeholders
var effect_function
var battle_function

var display_occupancy_return

# Exports
export (PackedScene) var Card

# function to create list of Card objects [from hard folder]
func make_deck(deck):
	# Setup Directory object
	var dir = Directory.new()
	if dir.open("res://Cards") == OK:
		var card_file = File.new()
		dir.list_dir_begin(true, true)
		
		# Iterate through Card Files
		var file_name = dir.get_next()
		while file_name != "":
			card_file.open("res://Cards/" + file_name, card_file.READ)
			var card = Card.instance()
			var ended = false
			
			# Set Card attributes
			var next_attr = card_file.get_csv_line(":")
			while !ended:
				card.set(next_attr[0], next_attr[1])
				if !card_file.eof_reached():
					next_attr = card_file.get_csv_line(":")
				else:
					ended = true
					
			card_file.close()
			
			# Connect Card to systems
			card.connect("click", self, "mouse_input", [card])
			deck.append(card)
			
			file_name = dir.get_next()
			
		dir.list_dir_end()
	return deck

# function to remove Card from list and add to Field
func draw_card(deck, field):
	var draw = deck.pop_front()
	
	# Setup Card's Image & Size
	var loadedImage = load("res://Card Art/" + draw.IMAGE)
	draw.get_node("Art").set_texture(loadedImage)
	var sizeDraw = Vector2(loadedImage.get_size())
	sizeDraw.x = 128 / sizeDraw.x
	sizeDraw.y = 128 / sizeDraw.y
	draw.get_node("Art").set_scale(sizeDraw)
	
	field.add_child(draw)
	update_card_gui(draw)
	# Update Field to include Card
	draw_field(field, 50)
	
# function to update the dynamic information on a card
func update_card_gui(card):
	card.get_node("Infotext").parse_bbcode("[center][color=black]" + card.NAME) # Card Name
	card.get_node("Occupie").parse_bbcode("[u][color=red]" + str(card.OCCUPANCY)) # Occupancy Number
	card.get_node("Invul_Decal").visible = card.INVUL # Invulnerable Tint
	
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
	
# function to check if an object is a Card
func check_card(object):
	return object.get_filename() == Card.get_path()
	
# function to move Card from Shadow/Light Field to the other
func move_card(card, side, dest_field):
	# Reparent Card
	card.get_parent().remove_child(card)
	side.get_node(dest_field).add_child(card)
	# Visually Update Card [moved parents]
	update_card_gui(card)
	# Redraw both Fields on affected Side
	draw_field(side.get_node("Shadow_Field"), 50)
	draw_field(side.get_node("Light_Field"), 50)
	
# function to set a card's values to their defaults
func default_card(card):
	card.OCCUPANCY = 1 # All cards have 1 occ. factor
	card.INVUL = false # All cards are not invulnerable
	update_card_gui(card)
	
# function to setup and takedown card targeting from user
func select_target():
	
	# Highlight relevant cards
	for i in legal_fields:
		var card_count = i.get_children()
		for j in card_count:
			if check_card(j):
				j.get_node("Target_Decal").visible = true
	
	# Prompt and Yield to the user
	print("Select a target.")
	yield()
	print("A target was selected.")
	
	# De-highlight relevant cards
	for i in legal_fields:
		var card_count = i.get_children()
		for j in card_count:
			if check_card(j):
				j.get_node("Target_Decal").visible = false
	
# function to determine a Card's effect and enact it
func activate_effect(card):
	
	# Initialize key terms and corresponding nodes
	var target_names = ["self"]
	var target_cards = [card]
	
	var target
	var effect = card.LIGHT_EFFECT.split(",")
	
	# Determine if Target is pre-determined
	if int(effect[0]) == 0:
		target = target_cards[target_names.find(effect[1])]
	else:
		var restriction = effect[1].split("/")
		
		# Determine valid Fields to choose Target from
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
		
		# Obtain Target from user
		var select_function = select_target()
		target = yield()
		select_function.resume()
		
	# Determine type of Effect and alter Cards accordingly
	if effect[2] == "occ":
		target.OCCUPANCY += int(effect[3])
	elif effect[2] == "inv":
		target.INVUL = true
	else:
		print(effect[2]) # print unknown effects
	update_card_gui(target)
	
	return card # used by mouse_input function
	
# function to countdown Occupancys during Battle
func display_occupancys(allies, enemies):
	
	# Determine starting enemy (can probably hardcode to 1?)
	var curr_enemy = 0
	while curr_enemy < len(enemies) and enemies[curr_enemy].get_filename() != Card.get_path():
		curr_enemy += 1

	var enemy_alive = true
	var excess_occupancy = 0
	
	# Iterate through ally Occupancies
	for i in allies:
		if check_card(i):
			while i.OCCUPANCY > 0:
				i.OCCUPANCY -= 1
				if enemy_alive:
					
					# Update Cards
					update_card_gui(i)
					enemies[curr_enemy].OCCUPANCY -= 1
					update_card_gui(enemies[curr_enemy])
					
					# Pause for user observation
					get_node("Sleep").start()
					yield(get_node("Sleep"), "timeout")
					
					# Determine if enemies with Occupancy remain
					if enemies[curr_enemy].OCCUPANCY <= 0:
						curr_enemy += 1
						if curr_enemy >= len(enemies):
							print("You win.")
							enemy_alive = false
				else:
					excess_occupancy += 1 # total_ally_occ - total_enemy_occ

	display_occupancy_return = excess_occupancy # use global for return since function yields with signal

# function to run through and determine the outcomes of Battle
func battle_phase():
	
	# Get lists of allies and enemies
	var allies = get_child(phase[0]).get_node("Light_Field").get_children()
	var enemies = get_child((phase[0] - 1) * -1).get_node("Light_Field").get_children()
	
	# Determine if battle is trivial (only one side)
	if len(allies) == 1:
		print("You have no one to use in battle.")
	elif len(enemies) == 1:
		print("You have no one to battle with.")
		
	else:
		display_occupancys(allies, enemies)
		var kill_power = yield()
		if kill_power > 0:
			legal_fields = [enemies[0].get_parent()]
			while len(legal_fields[0].get_children()) > 1:
				
				# Prompt and Obtain kill targets from user
				print("You may destroy ", kill_power, " targets.")
				var select_function = select_target()
				var target = yield()
				select_function.resume()
				
				# Remove Target from Field
				target.monitoring = false
				legal_fields[0].remove_child(target)
				draw_field(legal_fields[0], 50)
				
				kill_power -= 1
			
		else:
			print("You don't win.")
			
		# Reset all Cards to default
		for i in allies:
			if check_card(i):
				default_card(i)
		for i in enemies:
			if check_card(i):
				default_card(i)

	phase[1] = "End"
	
	# battle_function = null

# function to detect a selected card and send it to a yielded function
func send_target(object, resume_function):
	var valid = true
	# Determine if Card is valid target
	if check_card(object) and object.get_parent() in legal_fields:
		object = resume_function.resume(object)
	else:
		print("That is not a valid target.")
		valid = false
	return [valid, object]
		
# function to catch GUI input and decide what to do
func mouse_input(object):
	
	# Determine if seeking for a Target
	if phase[1] == "Activate":
		var valid = send_target(object, effect_function)
		if valid[0]:
			move_card(valid[1], get_child(phase[0]), "Light_Field")
			phase[1] = "Prep"
	elif phase[1] == "Battle":
		send_target(object, battle_function)
	
	else:
		# Determine if selection is on current side
		if get_child(phase[0]).is_a_parent_of(object):
			
			# Deck only during Draw Phase
			if object.get_name() == "Deck":
				if phase[1] == "Draw":
					draw_card(get("deck_" + str(phase[0])), get_child(phase[0]).get_node("Shadow_Field"))
					phase[1] = "Prep"
				else:
					print("You can't do that right now.")
					
			# Shadow Cards only during Prep Phase
			elif object.get_parent().get_name() == "Shadow_Field":
				if phase[1] == "Prep":
					
					# Activate Card Effect and Move if necesscary
					phase[1] = "Activate"
					effect_function = activate_effect(object)
					if not(effect_function is GDScriptFunctionState):
						move_card(object, get_child(phase[0]), "Light_Field")
						phase[1] = "Prep"
			
			# End: Prep to Battle; End to Other Player; Draw to Error
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
	# Check if ready to resume battle_function
	if display_occupancy_return != null:
		var temp_func = battle_function.resume(display_occupancy_return)
		if not(battle_function.is_valid(true)):
			battle_function = temp_func 
		display_occupancy_return = null
		
#		if battle_function is GDScriptFunctionState:
#			print("1", battle_function.is_valid())
#			print("2", battle_function.is_valid(true))
#			battle_function.resume(object)
#		else:
#			print("Nope")
