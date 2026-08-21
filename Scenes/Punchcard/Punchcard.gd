class_name Punchcard extends Resource
## A punchcard defines a dash direction from a set of options, and provides
## a blank plug-in for being decorated with extra functionality, like giving 
## an extra mid-air dash.

## The direction to dash with this card.
@export var _direction:Vector2 
func get_direction(): return _direction.normalized()

## The texture for this card.
@export var _texture:Texture2D 
func get_texture(): return _texture

## The function that's run when this punchcard is processed. Ripe for the decorating!
func run(to:Feedtape): to.dash_direction = get_direction()
