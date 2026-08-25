class_name DOUBLE extends PunchcardDecorator
## Doubles the length of the dash it's decorating.

func run_decoration(to:Feedtape) -> void: to.dash_timer *= 2
func get_overlay() -> Texture2D: 
	
	var new := GradientTexture1D.new()
	
	var grad := Gradient.new()
	grad.add_point(0.25, Color.BLACK)
	grad.add_point(0.75, Color.RED)
	
	new.gradient = grad
	
	return new
