extends ParallaxBackground

@export var speed = 100.0

func _process(delta):
	# Przesuwamy offset tła w lewo
	scroll_offset.x -= speed * delta
