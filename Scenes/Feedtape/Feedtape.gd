class_name Feedtape extends Control
## Manages dashing via a feedtape.

## Allow anyone to get the most-recently made instance.
static var _instance:Feedtape
static func get_instance() -> Feedtape: return _instance
func _init() -> void: _instance = self

const BOX_SIZE := 48

func _ready() -> void: 
	restart_feedtape()
	update_feedtape_display()

@onready var card_box        := $CardBox
@onready var progress_marker := $ProgressMarker

#region Dashing
signal dash_ended

## How many times the player can dash consequtively.
@export var dash_count := 1
var dashes_left = 0
## The velocity applied to the player during the dash.
@export var dash_velocity := 440.0
## How long all other input is locked in favor of the dash.
@export var dash_time := 0.25
var dash_timer := 0.0
## The cooldown before the player can dash again.
@export var dash_cooldown := 0.2
var dash_cooldown_timer := 0.0
## The buffer time for the dashing input.
@export var dash_buffer := 0.1
var dash_buffer_timer := 0.0
@export var max_after := 300.0

var dash_direction := Vector2.ZERO

## Ran in the player that's doing the dash's _physics_process.
## Ideally right before move_and_slide.
func _player_process(player:Player, delta:float) -> void:
	
	if player.is_on_floor(): dashes_left = dash_count
	
	## Tick down all the timers we're running.
	for timer_property in ["dash_timer", "dash_cooldown_timer", "dash_buffer_timer"]:
		var from := get(timer_property) as float
		var to := move_toward(from, 0.0, delta) as float
		
		if timer_property == "dash_timer" and from > 0 and to == 0:
			
			dash_cooldown_timer = dash_cooldown
			dash_ended.emit()
			
			var direction := player.velocity.normalized()
			var magnitude := minf(player.velocity.distance_to(Vector2.ZERO), max_after)
			
			player.velocity = direction * magnitude
		
		set(timer_property, to)
	
	## Input buffering.
	if Input.is_action_just_pressed("Dash"): dash_buffer_timer = dash_buffer
	
	## Starting the dash.
	if can_dash():
		dash_timer = dash_time
		dash_buffer_timer = 0.0
		dashes_left -= 1
		
		progress_feedtape()
	
	## Doing the dash.
	if is_dashing():
		## Do the dash. The thing.
		player.velocity = dash_direction * dash_velocity

## A few more-readable functions for state.
func is_dashing() -> bool: return dash_timer > 0
func on_cooldown() -> bool: return dash_buffer_timer > 0
func can_dash() -> bool:
	return (dash_buffer_timer > 0.0 
		and dash_cooldown_timer <= 0.0 
		and dash_timer <= 0.0 
		and dashes_left > 0)

#endregion

#region Feedtaping

var feedtape_index := 0:
	set(to):
		feedtape_index = wrap(to, 0, feedtape.size())
		progress_marker.position.x = (BOX_SIZE + card_box.get_theme_constant("separation")) * feedtape_index
var feedtape_direction := 1:
	set(to):
		feedtape_direction = signi(to)
@export var feedtape:Array[Punchcard]
var card_displays:Array[PunchcardDisplay]

func restart_feedtape() -> void:
	feedtape_index = 0
	feedtape_direction = 1

func set_feedtape(new_tape:Array[Punchcard]):
	feedtape = new_tape
	update_feedtape_display()
	restart_feedtape()

func update_feedtape_display() -> void:
	
	var slot_difference := signi(feedtape.size() - card_displays.size())
	
	## Need to change the number of TextureRects somehow. They're not the same.
	while slot_difference != 0:
		
		match slot_difference:
			# Need more TextureRects. Make more.
			1:  
				var new := PunchcardDisplay.new()
				card_box.add_child(new)
				card_displays.append(new)
			
			 # Need less TextureRects. Delete extra.
			-1: card_displays.pop_back().queue_free()
		
		# Update the slot diff.
		slot_difference = signi(feedtape.size() - card_displays.size())
	
	## Actually set all the overlays' textures to what they should be.
	for i in feedtape.size():
		card_displays[i].update_display(feedtape[i])

func progress_feedtape() -> void:
	
	## Crunch the current punchcard.
	feedtape[feedtape_index].run(self)
	card_displays[feedtape_index].update_display()
	
	feedtape_index += feedtape_direction

#endregion
