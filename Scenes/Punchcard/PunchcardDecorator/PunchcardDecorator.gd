@abstract
class_name PunchcardDecorator extends Punchcard
## A decoration for a punchcard that gives additional functionality.

func _init(target:Punchcard) -> void: decorates = target

var decorates:Punchcard

func run(to:Feedtape):
	decorates.run(to)  # Run the original program.
	run_decoration(to) # Run the decoration for the program.

## All decorators implement a function defining how they decorate the punchcard.
## Effectively the punchcard.
@abstract func run_decoration(to:Feedtape)
