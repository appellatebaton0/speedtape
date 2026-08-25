class_name CYCLE extends PunchcardDecorator
## Makes the decorator under it only run every other application.

@export var run_this_cycle := true # Whether the decorator will run this cycle.

func run_decoration(_to:Feedtape) -> void: run_this_cycle =! run_this_cycle

func run(to:Feedtape):
	if decorates is PunchcardDecorator and run_this_cycle: decorates.run(to)  # Run the original program.
	run_decoration(to) # Run the decoration for the program.

func get_overlay() -> Texture2D: 
	
	var new := GradientTexture1D.new()
	
	var grad := Gradient.new()
	grad.add_point(0.25, Color.BLACK)
	grad.add_point(0.75, Color.RED)
	
	new.gradient = grad
	
	return new
