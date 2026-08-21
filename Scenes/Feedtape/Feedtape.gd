class_name Feedtape extends Control
## Manages dashing via a feedtape.

## Allow anyone to get the most-recently made instance.
static var _instance:Feedtape
static func get_instance() -> Feedtape: return _instance
func _init() -> void: _instance = self

func _ready() -> void: restart_feedtape()

#region Dashing
signal dash_ended

## The velocity applied to the player during the dash.
@export var dash_velocity := 330.0
## How long all other input is locked in favor of the dash.
@export var dash_time := 0.4
var dash_timer := 0.0:
	set(to):
		if dash_timer > 0 and to <= 0:
			dash_cooldown_timer = dash_cooldown
			dash_ended.emit()
		dash_timer = to
## The cooldown before the player can dash again.
@export var dash_cooldown := 0.5
var dash_cooldown_timer := 0.0
## The buffer time for the dashing input.
@export var dash_buffer := 0.1
var dash_buffer_timer := 0.0

var dash_direction := Vector2.ZERO

## Ran in the player that's doing the dash's _physics_process.
## Ideally right before move_and_slide.
func _player_process(player:Player, delta:float) -> void:
	
	## Tick down all the timers we're running.
	for timer_property in ["dash_timer", "dash_cooldown_timer", "dash_buffer_timer"]:
		#print(timer_property, ": ", get(timer_property))
		set(timer_property, move_toward(get(timer_property), 0.0, delta))
	
	## Input buffering.
	if Input.is_action_just_pressed("Dash"): dash_buffer_timer = dash_buffer
	
	## Starting the dash.
	if dash_buffer_timer > 0.0 and dash_cooldown_timer <= 0.0 and dash_timer <= 0.0:
		dash_timer = dash_time
		dash_buffer_timer = 0.0
		
		progress_feedtape()
	
	## Doing the dash.
	if dash_timer > 0:
		## Do the dash. The thing.
		player.velocity = dash_direction * dash_velocity

## A few more-readable functions for state.
func is_dashing() -> bool: return dash_timer > 0
func on_cooldown() -> bool: return dash_buffer_timer > 0

#endregion

#region Feedtaping

var feedtape_index := 0:
	set(to):
		feedtape_index = wrap(to, 0, feedtape.size())
@export var feedtape:Array[Punchcard]

func restart_feedtape() -> void:
	feedtape_index = 0

func progress_feedtape() -> void:
	
	## Crunch the current punchcard.
	feedtape[feedtape_index].run(self)
	print("crunching ", feedtape[feedtape_index], " -> ", dash_direction)
	
	feedtape_index += 1

#endregion
