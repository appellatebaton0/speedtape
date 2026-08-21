class_name DashDecorator extends PunchcardDecorator

func run_decoration(to:Feedtape) -> void: to.dashes_left += 1
func get_overlay() -> Texture2D: return null
