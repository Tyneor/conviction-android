class_name Card extends ClickableArea
func get_class(): return "Card"

const DragStore = preload("res://stores/DragStore.tres")
const Theater = preload("res://scenes/Theater.tscn")
const CardDetails = preload("res://scenes/cards/CardDetails.tscn")

export var flipped := false setget set_flipped
#var draggable := false # in parent clickable area
var grabbed_offset : Vector2
var has_been_dragged := true
var label := "Card" setget set_label
var description : String setget ,get_description

func _ready():
	self.connect("pressed", self, "display_details")

func set_flipped(new_flipped):
	flipped = new_flipped
	$TextureRect/Label.visible = self.flipped

func set_label(new_label):
	label = new_label
	# TODO : set _on_enter_tree because label not changed
	if get_node_or_null("TextureRect/Label"):
		$TextureRect/Label.text = self.label

func set_font_size(new_font_size):
	$TextureRect/Label.get("custom_fonts/font").set_size(new_font_size)

func get_description():
	return "Description"
	
func compare_with(other_card):
	assert(self.get_class() != "Card" and other_card.get_class() != "Card", "Card is an abstract class that can't be compared")

func play_draw_animation(duration=1, flip_card=true):
	if flip_card:
		$AnimationPlayer.play("Draw")
	else:
		$AnimationPlayer.play("DrawWithoutFlip")
	if duration > 0:
		$AnimationPlayer.playback_speed = 1.0 / duration
	else:
		pass
#		$AnimationPlayer.advance(1)
	yield($AnimationPlayer, "animation_finished")

func play_reveal_animation(duration=1):
	if duration > 0:
		$AnimationPlayer.playback_speed = 1.0 / duration
	$AnimationPlayer.play("Reveal")
	yield($AnimationPlayer, "animation_finished")


func _input(event):
	if event is InputEventMouseMotion:
		self.has_been_dragged = true
		if DragStore.dragged_card == self:
			self.global_position = get_global_mouse_position() + self.grabbed_offset
		
	if event.is_action_released("ui_touch") and DragStore.dragged_card == self:
			var duration = DragStore.drop()
			yield(get_tree().create_timer(duration), "timeout")
			self.z_index = 0
		
func _input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("ui_touch"):
		self.has_been_dragged = false
		if draggable && DragStore.dragged_card == null:
			DragStore.drag(self)
			self.z_index = 1
			self.grabbed_offset = self.global_position - get_global_mouse_position()
		get_tree().set_input_as_handled()	
		
func display_details():
	if self.find_parent("Deck"):
		self.find_parent("Deck").display_details()
	elif self.flipped and not self.has_been_dragged:
		self.has_been_dragged = true
		var cardDetails = CardDetails.instance()
		cardDetails.set_label(self.label)
		cardDetails.set_description(self.description)
		var theater = Theater.instance()
		theater.set_content(cardDetails)
		get_tree().current_scene.add_child(theater)
