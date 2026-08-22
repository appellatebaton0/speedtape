class_name PunchcardDisplay extends TextureRect
## Displays a punchcard and all its decorators' overlays.

## The punchcard being displayed.
var _card:Punchcard

## When one of these is created...
func _init(set_card:Punchcard = null) -> void:
	## Set the card up.
	if set_card != null: update_card(set_card)
	
	## Set the size so that the texture(s) display correctly.
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	custom_minimum_size = Vector2.ONE * 48

## Update the current card, and the texture/displays, etc.
func update_card(to:Punchcard):
	_card = to
	
	## get_texture is always the underlying Punchcard's texture, so we don't 
	## have to worry about this returning a PunchcardDecorator null.
	texture = _card.get_texture() 
	
	var current_decorator:Punchcard = to
	var decorator_overlays:Array[Texture2D]
	
	## Trace down the chain of decorators (if any), picking up all the overlay_textures.
	while current_decorator is PunchcardDecorator: 
		decorator_overlays.append(current_decorator.get_overlay())
		current_decorator = current_decorator.decorates
	
	## Make a TextureRect for each of the found decorators (and reuse any existing ones).
	var texture_rects:Array[TextureRect]
	texture_rects.assign(get_children())
	
	## -1 for more TextureRects than overlays, 1 for the opposite, 0 for the same of each.
	var slot_difference := signi(decorator_overlays.size() - texture_rects.size())
	
	## Need to change the number of TextureRects somehow. They're not the same.
	while slot_difference != 0:
		
		print(slot_difference, " |> ", decorator_overlays.size(), "/", texture_rects.size())
		
		match slot_difference:
			# Need more TextureRects. Make more.
			1:  texture_rects.append(make_overlay_rect())
			
			 # Need less TextureRects. Delete extra.
			-1: texture_rects.pop_back().queue_free()
		
		# Update the slot diff.
		slot_difference = signi(decorator_overlays.size() - texture_rects.size())
	
	## Actually set all the overlays' textures to what they should be.
	for i in decorator_overlays.size():
		texture_rects[i].texture = decorator_overlays[i]

## Make a new overlay TextureRect, and add it as a child.
func make_overlay_rect() -> TextureRect:
	var new := TextureRect.new()
	
	new.custom_minimum_size = Vector2.ONE * 48
	new.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
	add_child(new)
	
	return new
