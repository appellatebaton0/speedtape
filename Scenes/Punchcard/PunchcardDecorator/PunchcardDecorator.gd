@abstract
class_name PunchcardDecorator extends Punchcard
## A decoration for a punchcard that gives additional functionality.

func _init(target:Punchcard = null) -> void: if target and not decorates: decorates = target

@export var decorates:Punchcard

## Pretends to be the original for direction & texture.
func get_direction(): return decorates.get_direction()
func get_texture():   return decorates.get_texture()

func run(to:Feedtape):
	if decorates: decorates.run(to)  # Run the original program.
	run_decoration(to) # Run the decoration for the program.

## All decorators implement a function defining how they decorate the punchcard.
## Effectively the punchcard.
@abstract 
func run_decoration(to:Feedtape) -> void

## Provide an additional texture that will be an overlay for the base punchcard.
@abstract 
func get_overlay() -> Texture2D
