extends Node
const Card = preload("res://scenes/Card.tscn")
const Auditor = preload("res://scenes/Auditor.tscn")

signal card_played

onready var deck = $Panel/Table/Left/OpponentDeck
onready var followers = $Panel/Table/Left/Followers
onready var hand = $Panel/Table/Right/OpponentHand
onready var arena = $OpponentArena
var card_set = []

func _ready():
	for i in range(10):
		var card = Card.instance()
		card.number = i
		card_set.append(card)

func start_set():
	self.reset_deck()
	for _i in range(3):
		var res = self.draw_card()
		if res is GDScriptFunctionState:
			yield(res, "completed")

func start_turn():
	self.play_random_card()
	yield(self, "card_played")
	if deck.slot.card:
		var res = self.draw_card()
		if res is GDScriptFunctionState:
			yield(res, "completed")
	elif hand.is_empty():
		self.start_set()

func reset_deck():
	card_set.shuffle()
	for card in card_set:
		var new_card = card.duplicate()
		new_card.number = card.number
		deck.add_card(new_card)

func draw_card():
	var slot = hand.first_empty_slot()
	if slot:
		var card = deck.draw_card()
		if card:
			yield(hand.add_card(card), "completed")

func play_random_card():
	print("Bot is thinking ...")
	yield(get_tree().create_timer(1.0), "timeout")
	if arena.slot.card == null:
		var card = hand.get_random_card()
		if card:
			arena.add_card(card)

func add_follower():
	var follower = Auditor.instance()
	var panel = Panel.new()
	var style = StyleBoxEmpty.new()
	panel.set("custom_styles/panel", style)
	panel.add_child(follower)
	panel.rect_min_size = Vector2(60, 60)
	followers.add_child(panel)
	follower.position += panel.rect_size / 2

func _on_OpponentArena_card_played():
	emit_signal("card_played")
