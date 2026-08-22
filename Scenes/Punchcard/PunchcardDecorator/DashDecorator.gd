class_name DashDecorator extends PunchcardDecorator

func run_decoration(to:Feedtape) -> void: to.dashes_left += 1
func get_overlay() -> Texture2D: 
	
	var new := GradientTexture1D.new()
	
	var grad := Gradient.new()
	grad.add_point(0.25, Color.BLACK)
	grad.add_point(0.75, Color.RED)
	
	new.gradient = grad
	
	print("RETURNIN'")
	return new
