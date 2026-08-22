class_name Player extends CharacterBody2D

## Allow anyone to get the most-recently made instance.
static var _instance:Player
static func get_instance() -> Player: return _instance
func _init() -> void: _instance = self

var feedtape:Feedtape:
	get():
		if feedtape == null:
			feedtape = Feedtape.get_instance()
		return feedtape

## The angle of a wall jump, as a normal vector
func get_wall_jump_angle() -> Vector2:
	return $WallJumpAngle.position.normalized()

#region Exported Variables

@export_group("Jumping")
## How long the jump input will buffer, so you can hit jump before being on the ground and still jump (in seconds).
@export var jump_buffering := 0.1
var jump_buffer := 0.0 # The current jump buffer
## How long the on_floor will save, so you can jump for a bit after leaving the ground (in seconds).
@export var coyote_jump_buffer := 0.1
var coyote_buffer := 0.0 # The current coyote jump buffer

## How much upwards velocity is applied on a jump.
@export var jump_velocity := 300.0

@export_group("Acceleration")
## How much the actor accelerates on the ground while trying to move, per second.
@export var floor_acceleration := 15.0
## How much the actor accelerates while trying to move, per second.
@export var air_acceleration := 15.0

@export_group("Friction")
enum friction_types{
	subtract, ## Subtract the value from the current speed.
	divide ## Divide the current speed by the value
	}

## How much the actor slows down while on the floor, per second.
@export var floor_friction := 15.0
## What kind of friction to use while on the floor
@export var floor_friction_type := friction_types.subtract

## How much the actor slows down while midair, per second.
@export var air_friction := 15.0
## What kind of friction to use while midair
@export var air_friction_type := friction_types.subtract

@export_group("")
## The maximum speed the actor can reach through this (other forces can apply more momentum).
@export var max_speed := 100.0
var speed:float = 0.0
## How much gravity affects the actor.
@export var gravity_multiplier := 1.0
@export var wall_slide_speed := 160.0
@export var wall_slide_gravity := 0.25
@export var wall_jump_multiplier := 1.2

#endregion

func _physics_process(delta: float) -> void:
	
	## Gravity
	if is_on_wall_only() and velocity.y >= 0:
		velocity += delta * get_gravity() * wall_slide_gravity 
		velocity.y = min(velocity.y, wall_slide_speed)
	elif not is_on_floor():
		velocity += delta * get_gravity() * gravity_multiplier
	
	## Jumping
	# Jump buffering
	jump_buffer = move_toward(jump_buffer, 0, delta)
	if Input.is_action_just_pressed("Jump"):
		jump_buffer = jump_buffering
	
	# Coyote jumping
	coyote_buffer = move_toward(coyote_buffer, 0, delta)
	if is_on_floor() or is_on_wall():
		coyote_buffer = coyote_jump_buffer
	
	# Jumping
	if jump_buffer > 0 and coyote_buffer > 0:
		
		## Give a little boost off the wall if wall-sliding.
		if is_on_wall_only():
			var jump_vector := Vector2(get_wall_normal().x, 1.0) * get_wall_jump_angle()
			
			velocity = jump_velocity * jump_vector * wall_jump_multiplier
		
		else:
			velocity.y = min(velocity.y, -jump_velocity)
		
		# Reset the buffers to prevent double jumping
		coyote_buffer = 0
		jump_buffer = 0
	
	## Movement
	var direction := Input.get_axis("Left", "Right")
	
	# Set acceleration and friction.
	var current_acceleration := floor_acceleration if is_on_floor() else air_acceleration
	var current_friction := floor_friction if is_on_floor() else air_friction
	if direction:
		# If the actor isn't already moving faster
		if not abs(velocity.x) > max_speed:
			velocity.x = move_toward(velocity.x, direction * max_speed, delta * current_acceleration * 60.0)
		
		# Friction! Move towards 0 based on the current friction.
		else:
			velocity.x = move_toward(velocity.x, 0, delta * current_friction * 60.0)
	else:
		velocity.x = move_toward(velocity.x, 0, delta * current_friction * 60.0)

	if feedtape: feedtape._player_process(self, delta)
	
	
	move_and_slide()
