class_name SKIP extends PunchcardDecorator
## Skips the card after this in the feedtape.

func run_decoration(to:Feedtape) -> void: to.feedtape_index += to.feedtape_direction
func get_overlay() -> Texture2D: 
	
	var new := GradientTexture1D.new()
	
	var grad := Gradient.new()
	grad.add_point(0.25, Color.BLACK)
	grad.add_point(0.75, Color.RED)
	
	new.gradient = grad
	
	return new
