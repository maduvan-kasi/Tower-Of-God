# Tower Of God
CCG developed with Godot 3  
By Maduvan Kasi ©2018  
  
Tower Of God [Working Title] is a Collectible Card Game implemented with the Godot 3 Engine.  
  
It seeks to bring a fresh experience to the genre by placing heavy restrictions on deck size, and reducing the number of  available card archetypes down to an incredible one.  
  
The project is currently still in early alpha and is, at the moment, unplayable.  

The current implementation only supports two local players. There are plans to implement both a CPU opponent, and a simple networking option, but work on either of these will not begin in the forseeable future.
  
<b> How it works: </b>  
  
Both players have 3 totems (which serve as LP/Health/Whatever) and a deck of 10 cards used to knock the other player's totems down to 0.  
  
The cards are all mechanically identical (no ATK/HP/mana/etc) except for their "Light Effect". (see below)  
Neither player has a "hand", but instead they have two "fields": a 'shadow' field, and a 'light' field.  
Cards are drawn from the deck (normally 1 per turn) and placed directly onto the player's Shadow Field.  
During a player's turn, any number of cards may be moved from the Shadow Field to the Light Field - doing so activates their 'Light Effect'.  
Once a player is done moving cards, they enter the battle phase, where their goal is to "occupy" (see below) all of their opponent's cards.  
After the battle phase, the player may choose one of their remaining Shadow Field cards as an "ambush" (see below). 
At this point, the player's turn ends, and play passes on to the opponent.  

<b> Light Effects </b>  
  
All cards have their own unique Light Effect, which activates whenever they are sent from the Shadow Field to the Light Field. These effects are of varying natures, from altering a card's Occupy Factor, to making it immune, to returning it to the Shadow Field. Any changes made to cards as a result of Light Effects only last till the end of the turn.  
  
<b> Occupying The Enemy </b>  
  
During a player's battle phase, all of the cards in their Light Field must occupy all of the cards in their opponent's Light Field. Ignoring all Light Effects, all cards have an Occupy Factor of 1 - this means that, ignoring all effects, a player needs at least as many cards as their opponent in the Light Field to completely occupy them. Once all of an opponent's Light Field cards are occupied, any of the player's excess Light Field cards may destroy the opponent's. If all of an opponent's Light Field cards have been destroyed, and the player still has excess Light Field cards that have not used their Occupy Factor, he/she may attack the opponent directly (only once per turn), thus destroying one of their totems.

<b> Setting up an Ambush </b>  
  
More info to come soon. It's more or less a Trap Card from Yu-gi-oh.  
  
<b> Misc. Notes </b>  
  
Ignoring Light Effects, cards in the Light Field cannot return to the Shadow Field.  
Both fields can only hold a maximum of 5 cards.  
  Should the Shadow Field be full at the start of a player's turn, a card will not be drawn.  
  Should the Shadow Field be full when a card is sent there via effect, the card will be destroyed.  
  Should the Light Field be full, the player may not activate any Light Effects.  
  Should the Light Field be full when a card is sent there via effect, a random card already in the Light Field will be destroyed to make space.  
When a player runs out of cards in their deck, they simply stop drawing at the start of their turns.  
Aside from activating ambushes, the opponent generally has no actions to take during a player's turn.  
A deck may only carry a single copy of every card.  
